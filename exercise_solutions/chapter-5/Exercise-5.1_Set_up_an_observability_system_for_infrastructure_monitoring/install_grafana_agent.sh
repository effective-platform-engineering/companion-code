#! /bin/bash
# This script installs the Grafana Agent for observability in a Kubernetes cluster.
set -e
CLUSTER_NAME="ex-5"
NAMESPACE="observability"

# Install the Grafana Agent
helm upgrade --install grafana-agent grafana/grafana-agent \
  -n $NAMESPACE --create-namespace \
  --values values-grafana-agent.yaml

# Wait for the Grafana Agent pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana-agent -n $NAMESPACE --timeout=180s

# Check if the Grafana Agent pod is running
echo "Checking if Grafana Agent is running..."
if kubectl get pods -n $NAMESPACE | grep -q "grafana-agent.*Running"; then
    echo "Grafana Agent is running successfully."
else
    echo "Grafana Agent failed to start. Please check the pod logs for more details."
    kubectl logs -l app.kubernetes.io/name=grafana-agent -n $NAMESPACE
    exit 1
fi