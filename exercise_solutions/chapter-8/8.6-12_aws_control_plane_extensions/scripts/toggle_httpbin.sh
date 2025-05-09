#!/usr/bin/env bash
set -eo pipefail

export toggle=$1
export cluster_name=$2

node_count () {
  nodes=$(kubectl get nodes -l kubernetes.io/arch=amd64 | tail -n +2 | wc -l | xargs)
  echo "current node count $nodes"
}

echo "toggle $toggle httpbin test instance on $cluster_name"

cat <<EOF > test/httpbin/virtual-service.yaml
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: httpbin
  namespace: default-mtls
spec:
  hosts:
  - "httpbin.$cluster_name.epetech.io"
  gateways:
  - istio-system/$cluster_name-epetech-io-gateway
  http:
    - route:
      - destination:
          host: httpbin.default-mtls.svc.cluster.local
          port:
            number: 80
EOF

if [[ $toggle == "on" ]]; then
  echo "deploy httpbin to default-mtls"
  node_count

  kubectl apply -f test/httpbin --recursive
  sleep 180

  node_count
fi

if [[ $toggle == "off" ]]; then
  echo "delete httpbin from default-mtls"

  kubectl delete -f test/httpbin --recursive
fi
