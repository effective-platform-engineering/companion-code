#!/usr/bin/env bats

@test "validate block volume claim created" {
  run bash -c "kubectl exec -it block-test-pod -n test-system -- ls -al /dev/xvda"
  [[ "${output}" =~ "dev/xvda" ]]
}

@test "validate claim-test-pod health" {
  run bash -c "kubectl get all -n test-system | grep 'pod/block-test-pod'"
  [[ "${output}" =~ "Running" ]]
}

@test "validate dynamic ebs pvc write access" {
  run bash -c "kubectl exec -ti block-test-pod -n test-system -- dd if=/dev/zero of=/dev/xvda bs=1024k count=100"
  [[ "${output}" =~ "100+0 records in" ]]
}