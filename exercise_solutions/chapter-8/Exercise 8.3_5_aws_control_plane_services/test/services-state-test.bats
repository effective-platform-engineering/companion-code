#!/usr/bin/env bats

@test "metrics-server status is Running" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'metrics-server'"
  [[ "${output}" =~ "Running" ]]
}

@test "endpoint returns architectural context info, running on arm64" {
  run bash -c "kubectl get --raw '/apis/metrics.k8s.io/v1beta1/nodes'"
  [[ "${output}" =~ "kubernetes.io/arch" ]]
  [[ "${output}" =~ "arm64" ]]
}

@test "kube-state-metrics status is Running" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'kube-state-metrics'"
  [[ "${output}" =~ "Running" ]]
}

@test "kube-state-metrics logs show service has started successfully" {
  run bash -c "kubectl logs deployment/kube-state-metrics -n kube-system -c kube-state-metrics"
  [[ "${output}" =~ "Started kube-state-metrics self metrics server" ]]
}

@test "event-exporter status is Running" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'event-exporter'"
  [[ "${output}" =~ "Running" ]]
}

@test "event-exporter logs show service has started successfully" {
  run bash -c "kubectl logs deployment/event-exporter -n kube-system -c event-exporter"
  [[ "${output}" =~ "Starting with config" ]]
}
