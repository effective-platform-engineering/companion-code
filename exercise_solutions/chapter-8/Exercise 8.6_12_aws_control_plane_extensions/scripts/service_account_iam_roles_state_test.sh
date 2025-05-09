#!/usr/bin/env bash
source bash-functions.sh
set -eo pipefail

cluster_name=$1
export aws_account_id=$(jq -er .aws_account_id "$cluster_name".auto.tfvars.json)
export aws_assume_role=$(jq -er .aws_assume_role "$cluster_name".auto.tfvars.json)
export AWS_DEFAULT_REGION=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)

awsAssumeRole "${aws_account_id}" "${aws_assume_role}"

rspec test/service_account_iam_roles.rb --format documentation
