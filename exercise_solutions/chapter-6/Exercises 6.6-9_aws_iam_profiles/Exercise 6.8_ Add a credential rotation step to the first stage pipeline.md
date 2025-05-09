### **6.8 Exercise: Add a credential rotation step to the first stage pipeline**

Add a credential rotation step to the after-apply parameters of our terraform apply pipeline step. This will come after the AWS integration tests.

    After-apply:  
      \- aws-integration-tests:  
          account: nonprod  
      \- rotate-service-account-credentials:  
          account: nonprod

Now, define a local command that will use the iam-credential-rotation utility to rotate our service account credentials and store the resulting new credentials in our 1Password vault, overwriting the existing service account credentials.

### **Solutions to Exercise 6.8: Add a credential rotation step to the first stage pipeline**

Add the rotate-service-account-credentials command.

command:

  rotate-service-account-credentials:  
    parameters:  
      account:  
        description: use this account environment values  
        type: string  
    Steps:  
      \- run:  
          name: create or rotate all service account credentials  
          command: bash scripts/rotate\_svc\_acct\_credentials.sh \<\< parameters.account \>\>

This command will call a local bash script, passing the name of the tfvars file to use to find the correct account information.

Now, create the bash script that will use iam-credential-rotation to fetch new credentials, removing the oldest, and then save those credentials to 1password overwriting the existing values.

\#\!/usr/bin/env bash  
source bash-functions.sh

set \-eo pipefail

export environment=$1  
export aws\_account\_id=$(jq \-er .aws\_account\_id "$environment".auto.tfvars.json)                                    \#A  
export aws\_assume\_role=$(jq \-er .aws\_assume\_role "$environment".auto.tfvars.json)  
export AWS\_DEFAULT\_REGION=$(jq \-er .aws\_region "$environment".auto.tfvars.json)

awsAssumeRole "${aws\_account\_id}" "${aws\_assume\_role}"               \#B

\# Rotate AWS IAM User access credentials. [https://pypi.org/project/iam-credential-rotation/](https://pypi.org/project/iam-credential-rotation/)  
echo "rotate service account credentials"  
iam-credential-rotation PlatformServiceAccounts \> machine\_credentials.json  \#C

\# Write new nonprod sa credentials to 1password  
echo "write NonprodServiceAccount credentials"

NonprodServiceAccountCredentials=$(jq \-er .NonprodServiceAccount machine\_credentials.json)                                              \#D  
NonprodAccessKey=$(echo $NonprodServiceAccountCredentials | jq .AccessKeyId | sed 's/"//g' | tr \-d \\\\n)  
NonprodSecret=$(echo $NonprodServiceAccountCredentials | jq .SecretAccessKey | sed 's/"//g' | tr \-d \\\\n)

write1passwordField "my-vault" "aws-account-2" "NonprodServiceAccount-aws-access-key-id" "$NonprodAccessKey"    \#E  
write1passwordField "my-vault" "aws-account-2" "NonprodServiceAccount-aws-secret-access-key" "$NonprodSecret"

\# Write new prod sa credentials to 1password vault                   \#F  
echo "write ProdrodServiceAccount credentials"  
ProdServiceAccountCredentials=$(jq \-er .ProdServiceAccount machine\_credentials.json)  
ProdAccessKey=$(echo $ProdServiceAccountCredentials | jq .AccessKeyId | sed 's/"//g' | tr \-d \\\\n)  
ProdSecret=$(echo $ProdServiceAccountCredentials | jq .SecretAccessKey | sed 's/"//g' | tr \-d \\\\n)

write1passwordField "my-vault" "aws-account-2" "ProdServiceAccount-aws-access-key-id" "$ProdAccessKey"  
write1passwordField "my-vault" "aws-account-2" "ProdServiceAccount-aws-secret-access-key" "$ProdSecret"

**\#A** We load the aws account id, role to assume, and default region from the current tfvar file in use.

**\#B** Then we use the same awsAssumeRole bash function we used in our awspec test to fetch short-lived credentials based on the role we must assume to perform this task.

**\#C** Use the iam-credential-rotation script to rotate both of service accounts, capturing the output into a local file.

**\#D** The next three lines parse out the credential values for the NonprodServiceAccount from the file output of the rotation utility.

**\#E** Now we will make use of the second bash function that the do/bash-functions orb command made available to us locally; write1passwordField. You can review the details of the command in the source code of the orb. But to summarize, the script will use the 1password cli that is preinstalled on the executor we are using, and our 1password credentials from our environment to update the contents of the location where we stored the service account credentials.

**\#F** And finally, we repeat the instructions to save the new credentials for the ProdServiceAccount.