### **Exercise 6.6: Bootstrap our nonproduction and production AWS accounts with the initial service accounts and pipeline role**

Create a new repository called aws-iam-profiles. Create the following files and folder structure, and use the concepts we discussed above to add the file contents that can be used to bootstrap our accounts. In these exercises, we will only be using two AWS accounts.

aws-iam-profiles/  
     environments/  
         nonprod.auto.tfvars.json.tpl  
         prod.auto.tfvars.json.tpl  
    service-accounts.tf  
    aws-iam-profiles-role.tf  
    variables.tf  
    versions.tf

Use your own credentials and administrator role permissions to apply the resources to the appropriate accounts with the matching tfvars.

Hint: Remember, we use Terraform Cloud for our backend state store. By default, a new workspace created in Terraform Cloud will be in *remote* execution mode; however, we will be operating in *local* execution mode. Local mode means we are not using the Terraform Cloud’s additional paid features. Set our Terraform cloud organization default to local mode. The Terraform orb we are using can manage the setting on a per-workspace basis, or you can set it within the Terraform cloud UI if you prefer.

Also, since you are using your credentials and permissions as part of this bootstrap, comment out the terraform assume\_role details in the aws provider definition. We can uncomment those lines once the service accounts are set up and credentials are available.

### **Solutions to Exercise 6.6: Bootstrap our nonproduction and production AWS accounts with the initial service accounts and pipeline role**

Starting with the role permission that will be needed by this pipeline to manage IAM Users,  Groups, Policies, and Roles.

In good TDD form, create a folder called test and add an AwsSpec test called platform\_iam\_profiles\_role\_spec.rb. Test for the role and the permissions we want the role to provide.

require 'awspec'

describe iam\_role('PlatformIamProfilesRole') do  
  it { should exist }  
  it { should have\_iam\_policy('PlatformIamProfilesRolePolicy') }  
  it { should be\_allowed\_action('iam:\*') }                        \#A  
end

**\#A** Normally, don’t use a wildcard to define permission details. Review the available IAM permissions[^1] and decide which ones you think a pipeline will need. Include matching lines for each permission needed. Getting the permission list correct can take a few iterations. A detailed example is provided in the companion code for these exercises.

Use your own AWS credentials for the first account and confirm that the test will run. You should expect to see a failing test result as we have not yet applied this configuration.

$ rspec test/platform\_iam\_profiles\_role\_spec.rb \--format documentation

iam\_role 'PlatformIamProfilesRole'

  is expected to exist (FAILED \- 1\)

  is expected to have iam policy "PlatformIamProfilesRolePolicy" (FAILED \- 2\)  
  ...

Failures:

  1\) iam\_role 'PlatformIamProfilesRole' is expected to exist  
     Failure/Error: it { should exist }  
     expected iam\_role 'PlatformIamProfilesRole' to exist  
     ...

Finished in 1.3 seconds (files took 5.68 seconds to load)  
5 examples, 5 failures

Create similar tests for our service accounts. Keep in mind, in a multiaccount setting, we won’t run those tests against every account just the account where the services accounts are created. One method is to put this test into a subfolder in the test folder. By default rspec will not recursively go through tests in a folder.

$ cat test/state/platform\_iam\_service\_accounts\_spec.rb

require 'awspec'

describe iam\_group('NonprodServiceAccountGroup') do  
  it { should exist }  
  it { should have\_iam\_user('NonprodServiceAccount') }  
end

describe iam\_policy('NonprodServiceAccountGroup') do  
  it { should exist }  
end

describe iam\_group('ProdServiceAccountGroup') do  
  it { should exist }  
  it { should have\_iam\_user('ProdServiceAccount') }  
end

describe iam\_policy('ProdServiceAccountGroup') do  
  it { should exist }  
end

With both of our tests happily failing, let’s write the terraform code to create the first role. 

\# platform-iam-profiles-role.tf

module "PlatformIamProfilesRole" {  
  Source \= "terraform-aws-modules/iam/aws//modules/iam-assumable-role"  
  version \= "5.40.0"                                                   \#A

  create\_role \= true

  role\_name               \= "PlatformIamProfilesRole"  
  role\_path               \= "/PlatformRoles/"  
  role\_requires\_mfa       \= false  
  custom\_role\_policy\_arns \= \[aws\_iam\_policy.PlatformIamProfilesRolePolicy.arn\]  
  number\_of\_custom\_role\_policy\_arns \= 1  
  trusted\_role\_arns \= \["arn:aws:iam::${var.state\_account\_id}:root"\]    \#B

}

**\#A** Pin the module to a specific version. While it is a good practice to pin modules to a particular commit SHA rather than a version tag as the module owner may move the commit to which a tag applies, keep in mind that some module registries, such the Hashicorp public terraform registry, do not yet support this practice.

**\#B** We define the account where our service-account identities live as the trusted source. In this example we are trusting any IAM User who has been granted access to assume roles outside the state account. Since we are the owners of this account and are only creating service accounts that should be able to do so this can be an acceptable starting point for simplicity sake. It is also good practice to narrow this to a more strictly identifiable source of service account identities. This is an example of where placing all service account users within a spefeici path would make that easier.

In the same file, we also need to define the aws\_iam\_policy resource to be attached to the role.

resource "aws\_iam\_policy" "PlatformIamProfilesRolePolicy" {  
  name \= "PlatformIamProfilesRolePolicy"  
  path \= "/PlatformPolicies/"                \#A  
  policy \= jsonencode({  
    "Version" : "2012-10-17"  
    "Statement" : \[  
      {  
        "Action" : \[  
          "iam:\*”                             \#B  
        \]  
        "Effect" : "Allow"  
        "Resource" : "\*"  
      },  
    \]  
  })  
}

**\#A** It is nearly always useful to place the platform level role policies into a dedicated path. This makes it easier to distinguish our product policies.

**\#B** Would not normally be a wildcard. Using this here for simplicity. See exercise code samples in github for a detailed example.

Next we need to add terraform resources for managing our service accounts. Put the service account resources in service\_accounts.tf

module "NonprodServiceAccount" {  
  source  \= "terraform-aws-modules/iam/aws//modules/iam-user"  
  version \= "5.40.0"

  create\_user    \= var.is\_state\_account         \#A  
  name           \= "NonprodServiceAccount"  
  path           \= "/PlatformServiceAccounts/"  \#B  
  create\_iam\_access\_key         \= false         \#C  
  create\_iam\_user\_login\_profile \= false         \#D  
  force\_destroy                 \= true  
  password\_reset\_required       \= false  
}

**\#A** The service accounts should only be created in the state account. Use a terraform variable to indicate whether or not to create the identities based on the account being configured.

**\#B** Store all such service accounts in a single path. This will make it easier to manage the service account credentials.

**\#C** Do not use terraform to manage the access credentials. Though there are effective, secure means of letting terraform manage credentials, terraform is not well suited to automated credential rotation. Create and rotate these credentials as a separate pipeline step.

**\#D** Service accounts should not have console access.

As is, the above non-prod service account has no permissions. Define an IAM Group that grants members the ability to assume roles in all non-production accounts.

module "NonprodServiceAccountGroup" {  
  source \=  "terraform-aws-modules/iam/aws//modules/  
Iam-group-with-assumable-roles-policy"  
  version \= "5.37.1"

  count           \= var.is\_state\_account ? 1 : 0    \#A  
  name            \= "NonprodServiceAccountGroup"  
  path            \= "/PlatformGroups/"  
  assumable\_roles \= var.all\_nonprod\_account\_roles   \#B

  \# include the nonprod service account in this nonprod group  
  group\_users \= \[  
    module.NonprodServiceAccount.iam\_user\_name  
  \]  
}

**\#A** The service accounts should only be created in the state account.

**\#B** This variable is an environment parameter that defines a list of all the non-production accounts of the engineering platform and will look something like this:

"all\_nonprod\_account\_roles": \[  
  "arn:aws:iam::111111111111:role/PlatformRoles/\*",   \# state account  
  "arn:aws:iam::222222222222:role/PlatformRoles/\*",   \# sandbox account  
  "arn:aws:iam::333333333333:role/PlatformRoles/\*"    \# non-prod account  
\]

You will only need to list a single account if that is all you are using for exercise purposes.

Next, add the Production service account and group. These are identical to the nonprod definition except of course for the name and that it will be permitted to assume roles in the production accounts as well.

We also need a versions.tf file to pin terraform and the aws provider versions and to describe the location of our backend state store.

terraform {  
  required\_version \= "\~\> 1.9"                 \#A  
  required\_providers {  
    aws \= {  
      source  \= "hashicorp/aws"  
      version \= "\~\> 5.57"                     \#A  
    }  
  }

  backend "remote" {  
    hostname     \= "app.terraform.io"  
    organization \= "my\_terraform\_cloud\_org"  
    workspaces {  
      prefix \= "platform-iam-profiles-"       \#B  
    }  
  }  
}

provider "aws" {  
  region \= var.aws\_region  
  \# assume\_role {                             \#C  
  \#   role\_arn \= "arn:aws:iam::${var.aws\_account\_id}:role/${var.aws\_assume\_role}"  
  \#   session\_name \= "iam-profiles"  
  \# }

  default\_tags {                              \#D  
    tags \= {  
      product  \= "VitalSigns.online engineering platform"  
      pipeline \= "platform-iam-profiles"  
    }  
  }  
}

**\#A** Pin terraform and provider versions

**\#B** Use prefix names that match the repo name so that workspaces are easier to find. This backend example uses “remote” which is a reference to the terraform cloud account we set up and are using to store our state files.

**\#C** Normally, when this pipeline runs it will assume the platform-iam-profiles role, however when we first bootstrap this role we are not able to do so as the role doesn’t yet exist. Comment out this section until after we have done the initial manual application.

**\#D** Adopt a consistent tagging strategy. This is an organizational need more than a specifically engineering platform requirement. We will want to have a tagging strategies that lets us track and allocate costs. At minimum there should be a product identifier and a reference to the pipeline that orchestrates this code. For ease of moving between development tools, an effective choice is the repository name.

We need a variables.tf file to define each of the terraform variables used above. Use validations to help detect invalid configuration. Examples of variables validation:

variable "aws\_region" {  
  type \= string  
  validation {                                       \#A  
    condition     \= can(regex("\[a-z\]\[a-z\]-\[a-z\]+-\[1-9\]", var.aws\_region))  
    error\_message \= "Invalid AWS Region name."  
  }  
}

variable "aws\_account\_id" {  
  type \= string  
  validation {                                       \#B  
    condition \= length(var.aws\_account\_id) \== 12 && can(regex("^\\\\d{12}$", var.aws\_account\_id))  
    error\_message \= "Invalid AWS account ID"  
  }  
}

variable "aws\_assume\_role" { type \= string }

variable "is\_state\_account" {  
  description \= "create STATE account configuration?"  
  type        \= bool  
  default     \= false  
}

variable "state\_account\_id" {  
  description \= "arn principal root reference to state account id where all svc accounts are defined"  
  type        \= string  
  validation {                                      \#B  
    condition     \= length(var.state\_account\_id) \== 12 && can(regex("^\\\\d{12}$", var.state\_account\_id))  
    error\_message \= "Invalid AWS account ID"  
  }  
}

variable "all\_nonprod\_account\_roles" {  
  description \= "arn reference to \* roles for all non-production aws accounts; arn:aws:iam::\*\*\*\*\*12345:role/\*"  
  type        \= list(any)  
}

variable "all\_production\_account\_roles" {  
  description \= "arn reference to \* roles for all production aws accounts; arn:aws:iam::\*\*\*\*\*12345:role/\*"  
  type        \= list(any)  
}

**\#A** Enforces a format of two letters, followed by a dash, followed by several letters, then a dash, and finally a number.

**\#B** This account validator confirms 12 numbers. 

Finally, we need the list of actual values that should populate the variables for each account. If we were using the four accounts described in the usual enterprise greenfield setting, git push will trigger a pipeline that deploys this config to the state account. Subsequently, tag the commit to apply this configuration to the sandbox, nonprod, and prod account in order. In this simplified architecture the combined nonprod account environment values will be:

$ cat environments/nonprod.auto.tfvars.json.tpl

{  
  "aws\_region": "us-east-1",  
  "aws\_account\_id": "{{ op://my-vault/aws-2/aws-account-id }}",  \#A  
  "aws\_assume\_role": "PlatformRoles/PlatformIamProfilesRole",  
  "is\_state\_account": true,  
  "state\_account\_id": "{{ op://my-vault/aws-2/aws-account-id }}", \#B  
  "all\_nonprod\_account\_roles": \[  
    "arn:aws:iam::{{ op://my-vault/aws-2/aws-account-id }}:role/PlatformRoles/\*"  
  \],  
  "all\_production\_account\_roles": \[  
    "arn:aws:iam::{{ op://my-vault/aws-1/aws-account-id }}:role/PlatformRoles/\*"  
  \]  
}

$ cat environments/prod.auto.tfvars.json.tpl

{  
  "aws\_region": "us-east-2",  
  "aws\_account\_id": "{{ op://my-vault/aws-1/aws-account-id }}",  \#A  
  "aws\_assume\_role": "PlatformRoles/PlatformIamProfilesRole",  
  "is\_state\_account": false,  
  "state\_account\_id": "{{ op://my-vault/aws-2/aws-account-id }}",  
  "all\_nonprod\_account\_roles": \[  
    "arn:aws:iam::{{ op://my-vault/aws-2/aws-account-id }}:role/PlatformRoles/\*"  
  \],  
  "all\_production\_account\_roles": \[  
    "arn:aws:iam::{{ op://my-vault/aws-1/aws-account-id }}:role/PlatformRoles/\*"  
  \]  
}

**\#A** Account IDs are not generally considered secrets. But let’s use this first pipeline to introduce an effective pipeline management approach for secrets in the tfvars file.

**\#B** Since we are using the same account both as a state account as as the sandbox account, the values will be the same. 

The two environment value files are in the environments folder and are in the form of templates into which we will need to inject the account numbers. We will use an orb command to perform this step in the pipeline but for this bootstrap step we need to do it manually. Note that the template filenames suggested above includes the .auto. directive which will cause terraform to automatically load the values without needing to use the \-var-file flag. When this happens during a pipeline run, the step will write the file to the root folder and since this is taking place on the ephemeral runner no change is actually being made to the stored code. We can do this now manually for the account we are bootstrapping. 

$ op inject \-i environments/nonprod.auto.tfvars.json.tpl \-o nonprod.auto.tfvars.json

This is a good point to define a .gitignore file to prevent manually testing of actions that are intended for the ephemeral runner from accidently getting written into version control.

\#.gitignore  
.terraform\*            \#A  
\*.auto.tfvars.json     \#B

**\#A** Exclude the local files terraform creates. When run in the pipeline, Terraform will also generate these files but that is an ephemeral location that will not preserve the files.

**\#B** We discussed above a pattern where information inside an environment tfvars file could include injected, secure information. When doing that, an effective pattern is for the pipeline to pull the template from a folder and write the contents to the root location as an auto.tfvars. Now the parameters will be included in the terraform commands without needing to specifically include them. To prevent accidently including the results from populating a template into the repository history, ignore these \*.auto files.

Make sure you have the .terraformrc credential file setup on your workstation for access to the cloud state store. Using your personal AWS administrative credentials for the first account, work through the usual terraform init, plan, and apply stages at the command line until you have successfully created the two service accounts and added the initial platform-iam-profiles-role to the non-prod aws account. Remove the nonprod tfvars file, generate the prod tfvar file from the template and repeat the process to add the platform-iam-profiles-role to the prod aws account using your personal prod account credentials. Using  your personal credentials in a bootstrap results in the correct audit log contents.

Now that we are adding actual Terraform code, the trivy scans our commit hook triggers will start reporting warning messages. For example, trivy will warn that the service accounts we are creating do not have MFA configuration turned on and that various password policies related to console access are not met. These are basically false positives as service accounts cannot provide MFA information, nor are they granted console access. Add a .trivyignore file to turn off these sorts of warnings.

$ cat .trivyignore

\# ignore MFA warning for services accounts  
AVD-AWS-0123  
\# ignore password policy warnings.  
\# Service accounts are not allowed console access.  
AVD-AWS-0063  
AVD-AWS-0056  
AVD-AWS-0059

.python-version        \#C  
.ruby-version  
.venv  
credentials            \#D

**\#C** Using pre-commit and awspec means both Python and Ruby configuration information is needed. You do not necessarily need to preserve this information.

**\#D** Our example solution uses the python package iam-credential-rotation and writes the resulting new credentials to a file. In a pipeline, the file is ephemeral and secure and will not be preserved. But for local testing, if you use the python tool you will want to make sure to not accidentally store the results in the repository.

[^1]:  [https://docs.aws.amazon.com/service-authorization/latest/reference/list\_awsidentityandaccessmanagementiam.html](https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsidentityandaccessmanagementiam.html)