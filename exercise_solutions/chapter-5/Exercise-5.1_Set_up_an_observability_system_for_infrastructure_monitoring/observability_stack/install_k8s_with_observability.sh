#! /bin/bash
# This script installs a Kubernetes cluster with observability tools using kind and Helm.
set -e

CLUSTER_NAME="exercise-5"
NAMESPACE="observability"

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "kind is not installed. Please install kind first: https://kind.sigs.k8s.io/docs/user/quick-start/"
    exit 1
fi

# Create a kind cluster with the specified configuration
kind create cluster --name $CLUSTER_NAME --config kind-config.yaml

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "Helm is not installed. Please install Helm first: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl first: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Set the context to the newly created kind cluster
kubectl config use-context kind-$CLUSTER_NAME

# Check if the context was set successfully
if [ "$(kubectl config current-context)" != "kind-$CLUSTER_NAME" ]; then
    echo "Failed to set the context to kind-$CLUSTER_NAME. Please check your kind installation."
    exit 1
fi

# Create a namespace for the observability tools
kubectl create namespace observability || true

# Add the Grafana and Prometheus Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm upgrade --install prometheus prometheus-community/prometheus \
  -n $NAMESPACE --create-namespace \
  -f prometheus-values.yaml
helm upgrade --install lgtm grafana/lgtm-distributed \
  -n $NAMESPACE --create-namespace \
  -f grafana-lgt-values.yaml

# Wait for the Prometheus pod to be ready
echo ""
echo "Waiting for Prometheus to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n observability --timeout=180s

echo ""
echo "Waiting for Grafana to be ready..."
# Wait for the Grafana pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n observability --timeout=180s

echo ""
echo "Waiting for Loki to be ready..."
# Wait for the Loki pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=loki -n observability --timeout=180s

echo ""
echo "Waiting for Tempo to be ready..."
# Wait for the Tempo pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=tempo -n observability --timeout=180s

# Print login info
echo ""
echo "--------------------------------"
echo ""
echo "Login for all tooling is set as username:admin password:Epetech"

# Print the Grafana URL
echo ""
echo "Grafana is installed. You can access it at http://localhost:3000"
# Print the Prometheus URL
echo "Prometheus is installed. You can access it at http://localhost:9090"
echo ""
echo "--------------------------------"

echo ""
echo "Remember, when finished exploring, you can delete your cluster with:"
echo "kind delete cluster --name $CLUSTER_NAME"
