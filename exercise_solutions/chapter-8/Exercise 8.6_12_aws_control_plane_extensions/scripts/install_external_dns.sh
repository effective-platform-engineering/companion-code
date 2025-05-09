#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
chart_version=$(jq -er .external_dns_chart_version $cluster_name.auto.tfvars.json)
cluster_domains=$(jq -er .cluster_domains $cluster_name.auto.tfvars.json)
AWS_ACCOUNT_ID=$(jq -er .aws_account_id $cluster_name.auto.tfvars.json)

echo "external-dns chart version $chart_version"

# add domains to external-dns domainFilter
declare -a domains=($(echo $cluster_domains | jq -r '.[]'))
cat <<EOF > cluster-domains-values.yaml
domainFilters:
EOF

for domain in "${domains[@]}";
do
  echo "  - $domain" >> cluster-domains-values.yaml
done

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update

# perform trivy scan of chart with install configuration
trivyScan "external-dns/external-dns" "external-dns"  "$chart_version" "external-dns-values/$cluster_name-values.yaml"

helm upgrade --install external-dns external-dns/external-dns \
             --version v$chart_version \
             --namespace istio-system \
             --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::${AWS_ACCOUNT_ID}:role/PlatformRoles/${cluster_name}-external-dns-sa \
             --set txtOwnerId=$cluster_name-epetech \
             --values cluster-domains-values.yaml \
             --values external-dns-values/$cluster_name-values.yaml
