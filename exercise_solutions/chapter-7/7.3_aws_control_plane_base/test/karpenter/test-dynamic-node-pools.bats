#!/usr/bin/env bats

@test "validate amd node creation" {
  run bash -c "kubectl get po -n test-system | grep 'test-amd-node-pool'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate arm node creation" {
  run bash -c "kubectl get po -n test-system | grep 'test-arm-node-pool'"
  [[ "${output}" =~ "Running" ]]
}
