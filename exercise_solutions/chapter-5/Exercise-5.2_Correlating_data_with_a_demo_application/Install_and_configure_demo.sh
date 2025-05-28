#! /bin/bash
# This script installs and configures the PodInfo 
# demo application in a Kubernetes cluster.
set -e
NAMESPACE="demo"

# Install the PodInfo demo application using Helm
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

helm upgrade --install otel-demo \
  --namespace $NAMESPACE --create-namespace \
  --values otel-demo-values.yaml \
  open-telemetry/opentelemetry-demo