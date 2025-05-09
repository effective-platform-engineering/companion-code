#!/usr/bin/env bats

@test "validate multi-write access on app1" {
  run bash -c "kubectl exec -it app1 -n test-system -- tail -n 5 /data/out2.txt"
  [[ "${output}" =~ "UTC" ]]
}

@test "validate multi-write access on app2" {
  run bash -c "kubectl exec -it app2 -n test-system -- tail -n 5 /data/out1.txt"
  [[ "${output}" =~ "UTC" ]]
}