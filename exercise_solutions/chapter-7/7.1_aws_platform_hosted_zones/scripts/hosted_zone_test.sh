#!/usr/bin/env bash
source bash-functions.sh
set -eo pipefail

export environment=$1
export account=$2
export aws_account_id=$(jq -er ."${account}"_account_id "$environment".auto.tfvars.json)
export aws_assume_role=$(jq -er .assume_role "$environment".auto.tfvars.json)
export AWS_DEFAULT_REGION=us-east-1

echo "environment $environment"
echo "account $account"
echo "aws_account_id $aws_account_id"
echo "aws_assume_role $aws_assume_role"
echo "AWS_DEFAULT_REGION $AWS_DEFAULT_REGION"

awsAssumeRole "${aws_account_id}" "${aws_assume_role}"

rspec "test/${account}_account_spec.rb"
