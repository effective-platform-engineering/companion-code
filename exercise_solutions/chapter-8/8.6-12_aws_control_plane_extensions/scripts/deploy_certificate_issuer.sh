#!/usr/bin/env bash
source bash-functions.sh
set -eo pipefail

cluster_name=$1
export aws_account_id=$(jq -er .aws_account_id "$cluster_name".auto.tfvars.json)
export aws_assume_role=$(jq -er .aws_assume_role "$cluster_name".auto.tfvars.json)
export AWS_DEFAULT_REGION=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)

export cluster_domains=$(jq -er .cluster_domains "$cluster_name".auto.tfvars.json)
export issuer_email=$(jq -er .issuerEmail "$cluster_name".auto.tfvars.json)
export issuer_endpoint=$(jq -er .issuerEndpoint "$cluster_name".auto.tfvars.json)

awsAssumeRole "${aws_account_id}" "${aws_assume_role}"

# generate cluster issuer resource template
cat <<EOF > "${cluster_name}-cluster-issuer.yaml"
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-$cluster_name-issuer
spec:
  acme:
    server: $issuer_endpoint
    email: $issuer_email
    privateKeySecretRef:
      name: letsencrypt-$cluster_name
    solvers:
EOF

# add cluster managed domains to issuer
declare -a domains=($(echo $cluster_domains | jq -r '.[]'))
for domain in "${domains[@]}";
do
  export zone_id=$(aws route53 list-hosted-zones-by-name | jq --arg name "$domain." -r '.HostedZones | .[] | select(.Name=="\($name)") | .Id')
  cat <<EOF >> ${cluster_name}-cluster-issuer.yaml
    - selector:
        dnsZones:
          - "$domain"
      dns01:
        route53:
          region: ${AWS_DEFAULT_REGION}
          hostedZoneID: ${zone_id}
EOF
done

kubectl apply -f "$cluster_name-cluster-issuer.yaml"
