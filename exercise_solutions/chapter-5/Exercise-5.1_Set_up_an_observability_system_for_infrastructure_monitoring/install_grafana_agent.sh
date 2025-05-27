#! /bin/bash
# This script installs the Grafana Agent for observability in a Kubernetes cluster.
set -e
CLUSTER_NAME="ex-5"
NAMESPACE="observability"

# Install the Grafana Agent
helm upgrade --install grafana-agent grafana/agent \
  -n $NAMESPACE --create-namespace \
  --set mode=flow

# Deploy the agent flow configuration
kubectl apply -f agent-flow.yaml