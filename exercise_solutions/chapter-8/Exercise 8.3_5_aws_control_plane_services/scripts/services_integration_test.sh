#!/usr/bin/env bash
set -eo pipefail

# wait a minute for the services to be ready
sleep 60

# run basic smoketest for service health
bats test/services-state-test.bats

# run horizontalpodautoscaler test to confirm metrics-server working health
kubectl apply -f test/hpa-test-deployment.yaml
sleep 30
kubectl apply -f test/hpa-test-load-generator.yaml
sleep 120

replicas=$(kubectl get hpa php-apache -n test-system | awk 'NR > 1 { print $7 }')
echo "hpa reports $replicas replicas"

if [[ "$replicas" > 1 ]]; then
  echo "hpa-test replicas scaled under load."
else
  echo "error: hpa-test replicas not scaling under load."
  exit 1
fi
kubectl delete -f test/hpa-test-deployment.yaml
kubectl delete -f test/hpa-test-load-generator.yaml

# run test metrics output test to confirm kube-state-metrics and event-exporter health
bats test/services-functional-test.bats
