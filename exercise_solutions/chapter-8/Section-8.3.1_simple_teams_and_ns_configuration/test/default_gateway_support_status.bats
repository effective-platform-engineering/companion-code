#!/usr/bin/env bats

@test "evaluate simple teams external-dns pod status" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'simple-teams-external-dns'"
  [[ "${output}" =~ "Running" ]]
}

# confirm the cluster issuers have successfully resolved
@test "evlaute cluster issuers" {
  run bash -c "kubectl get clusterissuers"
  [[ ! "${output}" =~ "False" ]]
}

# gateways status tested in gateway functional tests
