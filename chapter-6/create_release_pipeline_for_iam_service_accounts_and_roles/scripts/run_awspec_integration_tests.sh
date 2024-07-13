#!/usr/bin/env bash
source bash-functions.sh
set -eo pipefail

export ENVIRONMENT=$1
export AWS_DEFAULT_REGION=$(cat ${ENVIRONMENT}.auto.tfvars.json | jq -r .aws_region)

awsAssumeRole $(cat ${ENVIRONMENT}.auto.tfvars.json | jq -r .aws_account_id) $(cat ${ENVIRONMENT}.auto.tfvars.json | jq -r .aws_assume_role)

# test roles
rspec test/*.rb --format documentation

# if this is the state account then test the profiles
if [[ ${ENVIRONMENT} == "nonprod" ]]; then
  rspec test/state-account/service_accounts_spec.rb --format documentation
fi
