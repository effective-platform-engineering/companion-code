#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
CHART_VERSION=$(jq -er .metrics_server_chart_version environments/$cluster_name.json)
echo "metrics-server chart version $CHART_VERSION"

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# perform trivy scan of chart with install configuration
trivyScan "metrics-server/metrics-server" "metrics-server"  "$CHART_VERSION" "metrics-server-values/$cluster_name-values.yaml"

helm upgrade --install metrics-server metrics-server/metrics-server \
             --version $CHART_VERSION \
             --namespace kube-system \
             --values metrics-server-values/$cluster_name-values.yaml
