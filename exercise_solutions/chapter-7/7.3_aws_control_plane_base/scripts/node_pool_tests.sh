#!/usr/bin/env bash
set -eo pipefail

# deploy test pod to default NodePools
kubectl apply -f test/karpenter/amd-node-pool-deployment.yaml
kubectl apply -f test/karpenter/arm-node-pool-deployment.yaml
sleep 120
bats test/karpenter/test-dynamic-node-pools.bats

kubectl delete -f test/karpenter/amd-node-pool-deployment.yaml
kubectl delete -f test/karpenter/arm-node-pool-deployment.yaml