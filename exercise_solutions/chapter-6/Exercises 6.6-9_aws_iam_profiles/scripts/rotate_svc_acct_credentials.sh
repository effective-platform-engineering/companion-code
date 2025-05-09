#!/usr/bin/env bash
source bash-functions.sh
set -eo pipefail

export environment=$1
export aws_account_id=$(jq -er .aws_account_id "$environment".auto.tfvars.json)
export aws_assume_role=$(jq -er .aws_assume_role "$environment".auto.tfvars.json)
export AWS_DEFAULT_REGION=$(jq -er .aws_region "$environment".auto.tfvars.json)

awsAssumeRole "${aws_account_id}" "${aws_assume_role}"

# Rotate AWS IAM User access credentials. https://pypi.org/project/iam-credential-rotation/
echo "rotate service account credentials"
iam-credential-rotation ServiceAccounts > machine_credentials.json

# Write new nonprod sa credentials to 1password
echo "write NonprodServiceAccount credentials"
NonprodServiceAccountCredentials=$(jq -er .NonprodServiceAccount machine_credentials.json)
NonprodAccessKey=$(echo $NonprodServiceAccountCredentials | jq .AccessKeyId | sed 's/"//g' | tr -d \\n)
NonprodSecret=$(echo $NonprodServiceAccountCredentials | jq .SecretAccessKey | sed 's/"//g' | tr -d \\n)

write1passwordField "my-vault" "aws-account-2" "NonprodServiceAccount-aws-access-key-id" "$NonprodAccessKey"
write1passwordField "my-vault" "aws-account-2" "NonprodServiceAccount-aws-secret-access-key" "$NonprodSecret"

# Write new prod sa credentials to 1password vault
echo "write ProdrodServiceAccount credentials"
ProdServiceAccountCredentials=$(jq -er .ProdServiceAccount machine_credentials.json)
ProdAccessKey=$(echo $ProdServiceAccountCredentials | jq .AccessKeyId | sed 's/"//g' | tr -d \\n)
ProdSecret=$(echo $ProdServiceAccountCredentials | jq .SecretAccessKey | sed 's/"//g' | tr -d \\n)

write1passwordField "my-vault" "aws-account-2" "ProdServiceAccount-aws-access-key-id" "$ProdAccessKey"
write1passwordField "my-vault" "aws-account-2" "ProdServiceAccount-aws-secret-access-key" "$ProdSecret"
