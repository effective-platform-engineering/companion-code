#!/usr/bin/env bash
source bash-functions.sh  # from orb-pipeline-events/bash-functions
set -eo pipefail

cluster_name=$1
export aws_account_id=$(jq -er .aws_account_id "$cluster_name".auto.tfvars.json)
export aws_assume_role=$(jq -er .aws_assume_role "$cluster_name".auto.tfvars.json)
export AWS_DEFAULT_REGION=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)

awsAssumeRole "${aws_account_id}" "${aws_assume_role}"

# aws integration smoke test
rspec test/*.rb
