#! /bin/bash
# This script installs the Grafana Alloy for observability in a Kubernetes cluster.
set -e
CLUSTER_NAME="exercise-5"
NAMESPACE="observability"

#Install the Alloy configuration from a file
kubectl create configmap \
  --namespace $NAMESPACE \
  alloy-config "--from-file=config.alloy=./config-map.alloy"

# Install Grafana Alloy
helm upgrade --install grafana-alloy grafana/alloy \
  -n $NAMESPACE \
  --atomic \
  --values grafana-alloy-values.yaml

# Wait for the Grafana Alloy pod to be ready
echo ""
echo "Waiting for Grafana Alloy to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alloy -n $NAMESPACE --timeout=180s

# Ensure the Grafana Alloy pod is running
echo ""
echo "Ensuring the Grafana Alloy is running..."
# Get pods associated with the Helm release
PODS=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=grafana-alloy" -o jsonpath='{.items[*].metadata.name}')
ALL_RUNNING=true
for POD in $PODS; do
  PHASE=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.status.phase}')
  if [[ "$PHASE" != "Running" ]]; then
    echo "Pod $POD is not running (status: $PHASE)"
    ALL_RUNNING=false
    continue
  fi
  # Check each container status
  READY_CONTAINERS=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[*].ready}' | tr ' ' '\n' | grep -c true)
  TOTAL_CONTAINERS=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[*].name}' | wc -w)

  if [[ "$READY_CONTAINERS" -ne "$TOTAL_CONTAINERS" ]]; then
    echo "Pod $POD has containers not ready ($READY_CONTAINERS/$TOTAL_CONTAINERS ready)"
    ALL_RUNNING=false
  else
    echo "Pod $POD is fully running with all containers ready"
  fi
done

if [ "$ALL_RUNNING" = true ]; then
  echo "All pods and containers for grafana-alloy are running!"
else
  echo "Some pods or containers are not in the Running state."
fi