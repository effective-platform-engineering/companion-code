#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
CHART_VERSION=$(jq -er .kubernetes_event_exporter_chart_version environments/$cluster_name.json)
echo "kubernetes-event-exporter chart version $CHART_VERSION"

# perform trivy scan of chart with install configuration
trivyScan "oci://registry-1.docker.io/bitnamicharts/kubernetes-event-exporter" "kubernetes-event-exporter" "$CHART_VERSION" "kubernetes-event-exporter-values/$cluster_name-values.yaml"

helm upgrade --install event-exporter oci://registry-1.docker.io/bitnamicharts/kubernetes-event-exporter \
             --version $CHART_VERSION \
             --namespace kube-system \
             --values kubernetes-event-exporter-values/$cluster_name-values.yaml
