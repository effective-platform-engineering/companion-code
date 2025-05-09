#!/usr/bin/env bash
set -eo pipefail

export cluster_name=$1

# launch test app in istio-managed namespace
bash scripts/toggle_httpbin.sh on $cluster_name

# all istio, external-dns, and cert-manager extensions must be healthy for this response to succeed
echo "test successful ingress, certs, dns management"
jsonResponse=$(curl -X GET "https://httpbin.$cluster_name.epetech.io/json" -H "accept: application/json")
echo "response $jsonResponse"
if [[ ! $jsonResponse =~ "slideshow" ]]; then
  echo "httpbin not responding"
  bash scripts/toggle_httpbin.sh off $cluster_name
  exit 1
fi

# ingress is configured to require TLS1.3 or higher, let's include a test for that
output=$(curl -Iiv --tlsv1.1 "https://httpbin.$cluster_name.epetech.io" 2>&1)
echo "testing TLSv1.3 uplevel with 1.1 communication attempt"
if [[ ! $output =~ "SSL connection using TLSv1.3" ]]; then
  echo "TLSv1.3 not enforced"
  bash scripts/toggle_httpbin.sh off $cluster_name
  exit 1
fi

# remove test app
bash scripts/toggle_httpbin.sh off $cluster_name
