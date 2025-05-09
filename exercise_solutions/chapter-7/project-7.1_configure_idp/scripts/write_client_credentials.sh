#!/usr/bin/env bash
set -eo pipefail

export tenant=$1
export web=$2

if [[ -f "$tenant-client_credentials.json" ]]; then
  echo "write auth0 $tenant cli client credentials"
  Auth0ClientCredentials=$(jq . < $tenant-client_credentials.json)
  TenantClientID=$(echo $Auth0ClientCredentials | jq .client_id | sed 's/"//g' | tr -d \\n)
  TenantClientSecret=$(echo $Auth0ClientCredentials | jq .client_secret | sed 's/"//g' | tr -d \\n)

  op item edit 'svc-auth0' $tenant-cli-client-id=$TenantClientID --vault my-vault >/dev/null
  op item edit 'svc-auth0' $tenant-cli-client-secret=$TenantClientSecret --vault my-vault >/dev/null
else
  echo "Existing client updates. No new credentials generated."
fi

if [[ -f "$web-client_credentials.json" ]]; then
  echo "write auth0 $web client credentials"
  Auth0ClientCredentials=$(jq . < $web-client_credentials.json)
  TenantClientID=$(echo $Auth0ClientCredentials | jq .client_id | sed 's/"//g' | tr -d \\n)
  TenantClientSecret=$(echo $Auth0ClientCredentials | jq .client_secret | sed 's/"//g' | tr -d \\n)

  op item edit 'svc-auth0' $web-client-id=$TenantClientID --vault my-vault >/dev/null
  op item edit 'svc-auth0' $web-client-secret=$TenantClientSecret --vault my-vault >/dev/null
else
  echo "Existing client updates. No new credentials generated."
fi