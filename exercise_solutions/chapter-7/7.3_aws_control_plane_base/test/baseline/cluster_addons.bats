#!/usr/bin/env bats

@test "evaluate kubeproxy" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'kube-proxy'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate ebs csi node deployment" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'ebs-csi-node'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate ebs csi controller deployment" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'ebs-csi-controller'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate efs csi node deployment" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'efs-csi-node'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate efs csi controller deployment" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'efs-csi-controller'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate aws-node" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'aws-node'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate core-dns" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'coredns'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate eks-pod-identity-agent" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'eks-pod-identity-agent'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate karpenter" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'karpenter'"
  [[ "${output}" =~ "Running" ]]
}