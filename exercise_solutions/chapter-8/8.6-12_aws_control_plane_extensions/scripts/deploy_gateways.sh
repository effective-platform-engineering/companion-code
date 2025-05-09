#!/usr/bin/env bash
set -eo pipefail

export cluster_name=$1
export cluster_domains=$(jq -er .cluster_domains "$cluster_name".auto.tfvars.json)
echo $cluster_name
echo $cluster_domains

declare -a domains=($(echo $cluster_domains | jq -r '.[]'))

for domain in "${domains[@]}";
do

  echo "create certificate for $domain"
  cat <<EOF > tpl/$domain-certificate.yaml
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: $domain-certificate
  namespace: istio-system
spec:
  secretName: $domain-certificate
  issuerRef:
    name: "letsencrypt-${cluster_name}-issuer"
    kind: ClusterIssuer
  commonName: "*.$domain"
  dnsNames:
  - "$domain"
  - "*.$domain"
EOF
  cat tpl/$domain-certificate.yaml
  kubectl apply -f tpl/$domain-certificate.yaml

  echo "define gateway for $domain"
  export gateway=$( echo $domain | tr . - )
  cat <<EOF > tpl/$domain-gateway.yaml
---
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: $gateway-gateway
  namespace: istio-system
  labels:
    istio: istio-ingressgateway
spec:
  selector:
    app: istio-ingressgateway
  servers:
    - port:
        number: 80
        name: http-$domain
        protocol: HTTP
      hosts:
      - "$domain"
      - "*.$domain"
      tls:
        httpsRedirect: true
    - port:
        number: 443
        name: https-$domain
        protocol: HTTPS
      hosts:
      - "$domain"
      - "*.$domain"
      tls:
        mode: SIMPLE
        credentialName: "$domain-certificate"
EOF
  cat tpl/$domain-gateway.yaml
  kubectl apply -f tpl/$domain-gateway.yaml

done

sleep 360