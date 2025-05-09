#!/usr/bin/env bats

@test "istiod pod status is Running" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'istiod'"
  [[ "${output}" =~ "Running" ]]
}

@test "istio-ingressgateway pod status is Running" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'ingressgateway'"
  [[ "${output}" =~ "Running" ]]
}

@test "istio-cni-node pod status is Running" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'istio-cni-node'"
  [[ "${output}" =~ "Running" ]]
}

@test "cert-manager pod status is Running" {
  run bash -c "kubectl get pods -n cert-manager -o wide | grep 'cert-manager'"
  [[ "${output}" =~ "Running" ]]
}

@test "cert-manager-cainjector pod status is Running" {
  run bash -c "kubectl get pods -n cert-manager -o wide | grep 'cert-manager-cainjector'"
  [[ "${output}" =~ "Running" ]]
}

@test "cert-manager-webhook pod status is Running" {
  run bash -c "kubectl get pods -n cert-manager -o wide | grep 'cert-manager-webhook'"
  [[ "${output}" =~ "Running" ]]
}

@test "external-dns pod status is Running" {
  run bash -c "kubectl get pods -n istio-system -o wide | grep 'external-dns'"
  [[ "${output}" =~ "Running" ]]
}
