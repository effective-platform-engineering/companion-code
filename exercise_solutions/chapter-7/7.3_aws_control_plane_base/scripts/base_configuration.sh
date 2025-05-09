#!/usr/bin/env bash
source bash-functions.sh  # from orb-pipeline-events/bash-functions
set -eo pipefail

cluster_name=$1
export AWS_REGION=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)
kubeconfig=$(cat ~/.kube/config | base64)

# store cluster identifiers in 1password vault
write1passwordField my-vault "${cluster_name}" kubeconfig-base64 "$kubeconfig"
write1passwordField my-vault "${cluster_name}" cluster-url $(terraform output -raw cluster_url)
write1passwordField my-vault "${cluster_name}" certificate-authority-data-base64 $(terraform output -raw cluster_public_certificate_authority_data)
write1passwordField my-vault "${cluster_name}" eks-efs-csi-storage-id $(terraform output -raw eks_efs_csi_storage_id)
write1passwordField my-vault "${cluster_name}" cluster-oidc-issuer-url $(terraform output -raw cluster_oidc_issuer_url)
eks_efs_csi_storage_id=$(terraform output -raw eks_efs_csi_storage_id)
karpenter_node_iam_role_name=$(terraform output -raw karpenter_node_iam_role_name)

# apply baseline cluster resources ================================

# create test-system and karpenter namespaces
kubectl apply -f tpl/system-namespaces.yaml

# create twdps-core-labs-team oidc admin clusterrolebinding
kubectl apply -f tpl/admin-clusterrolebinding.yaml

# create cluster ebs-csi storage class
cat <<EOF > tpl/ebs-csi-storage-class.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${cluster_name}-ebs-csi-dynamic-storage
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
parameters:
  csi.storage.k8s.io/fstype: xfs
  type: io1
  iopsPerGB: "50"
  encrypted: "true"
EOF
kubectl apply -f tpl/ebs-csi-storage-class.yaml

# create cluster efs-csi storage class
cat <<EOF > tpl/efs-csi-storage-class.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${cluster_name}-efs-csi-dynamic-storage
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: $eks_efs_csi_storage_id
  directoryPerms: "700"
  basePath: "/dynamic_storage"
  subPathPattern: \${.PVC.namespace}/\${.PVC.name}
  ensureUniqueDirectory: "true"
  reuseAccessPoint: "false"
EOF
kubectl apply -f tpl/efs-csi-storage-class.yaml

# create default Node Class, along with amd and arm node pools
cat <<EOF > tpl/default-node-class.yaml
---
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default-node-class
  namespace: karpenter
spec:
  amiFamily: Bottlerocket
  role: $karpenter_node_iam_role_name
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: $cluster_name-vpc
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: $cluster_name
EOF
kubectl apply -f tpl/default-node-class.yaml
kubectl apply -f tpl/default-amd-node-pool.yaml
kubectl apply -f tpl/default-arm-node-pool.yaml
