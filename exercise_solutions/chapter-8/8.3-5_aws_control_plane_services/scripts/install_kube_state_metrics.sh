#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
CHART_VERSION=$(jq -er .kube_state_metrics_chart_version environments/$cluster_name.json)
echo "kube-state-metrics chart version $CHART_VERSION"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# perform trivy scan of chart with install configuration
trivyScan "prometheus-community/kube-state-metrics" "kube-state-metrics" "$CHART_VERSION" "kube-state-metrics-values/$cluster_name-values.yaml"

helm upgrade --install kube-state-metrics prometheus-community/kube-state-metrics \
             --version $CHART_VERSION \
             --namespace kube-system \
             --values kube-state-metrics-values/$cluster_name-values.yaml
