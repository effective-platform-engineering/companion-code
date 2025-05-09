#!/usr/bin/env bats

@test "validate ebs volume expansion" {
  run bash -c "kubectl get pvc test-ebs-claim -n test-system | grep '8Gi'"
  [[ "${output}" =~ "Bound" ]]
}
