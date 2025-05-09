#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
chart_version=$(jq -er .cert_manager_chart_version $cluster_name.auto.tfvars.json)
AWS_ACCOUNT_ID=$(jq -er .aws_account_id $cluster_name.auto.tfvars.json)

echo "cert-manager chart version $chart_version"
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update

# perform trivy scan of chart with install configuration
trivyScan "jetstack/cert-manager" "cert-manager"  "v$chart_version" "cert-manager-values/$cluster_name-values.yaml"

helm upgrade --install cert-manager jetstack/cert-manager \
             --version v$chart_version \
             --namespace cert-manager --create-namespace \
             --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::${AWS_ACCOUNT_ID}:role/PlatformRoles/${cluster_name}-cert-manager-sa \
             --values cert-manager-values/$cluster_name-values.yaml

sleep 180