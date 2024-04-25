#!/usr/bin/env bash
source bash-functions.sh
set -eo pipefail

export ENVIRONMENT=$1
export AWS_DEFAULT_REGION=$(cat ${ENVIRONMENT}.auto.tfvars.json | jq -r .aws_region)

awsAssumeRole $(cat ${ENVIRONMENT}.auto.tfvars.json | jq -r .aws_account_id) $(cat ${ENVIRONMENT}.auto.tfvars.json | jq -r .aws_assume_role)

# Rotate AWS IAM User access credentials. https://pypi.org/project/iam-credential-rotation/
echo "rotate service account credentials"
iam-credential-rotation PlatformServiceAccounts > machine_credentials.json

# Write new nonprod credentials to 1password
echo "write NonprodServiceAccount credentials"
NonprodServiceAccountCredentials=$(jq .NonprodServiceAccount < machine_credentials.json)
NonprodAccessKey=$(echo $NonprodServiceAccountCredentials | jq .AccessKeyId | sed 's/"//g' | tr -d \\n)
NonprodSecret=$(echo $NonprodServiceAccountCredentials | jq .SecretAccessKey | sed 's/"//g' | tr -d \\n)

op item edit 'aws-dps-2' NonprodServiceAccount-aws-access-key-id=$NonprodAccessKey --vault empc-lab >/dev/null
op item edit 'aws-dps-2' NonprodServiceAccount-aws-secret-access-key=$NonprodSecret --vault empc-lab >/dev/null

# Write new prod credentials to 1password vault
echo "write ProdrodServiceAccount credentials"
ProdServiceAccountCredentials=$(jq .ProdServiceAccount <  machine_credentials.json)
ProdAccessKey=$(echo $ProdServiceAccountCredentials | jq .AccessKeyId | sed 's/"//g' | tr -d \\n)
ProdSecret=$(echo $ProdServiceAccountCredentials | jq .SecretAccessKey | sed 's/"//g' | tr -d \\n)

op item edit 'aws-dps-2' ProdServiceAccount-aws-access-key-id=$ProdAccessKey --vault empc-lab >/dev/null
op item edit 'aws-dps-2' ProdServiceAccount-aws-secret-access-key=$ProdSecret --vault empc-lab >/dev/null
