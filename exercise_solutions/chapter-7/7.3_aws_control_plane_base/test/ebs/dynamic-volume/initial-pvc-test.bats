#!/usr/bin/env bats

@test "validate dynamic ebs volume claim created" {
  run bash -c "kubectl describe pv | grep 'test-system/test-ebs-claim'"
  [[ "${output}" =~ "Claim" ]]
}

@test "validate claim-test-pod health" {
  run bash -c "kubectl get all -n test-system | grep 'pod/claim-test-pod'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate dynamic ebs pvc write access" {
  run bash -c "kubectl exec -it -n test-system claim-test-pod -- cat /data/out.txt"
  [[ "${output}" =~ "UTC" ]]
}