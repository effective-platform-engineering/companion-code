#!/usr/bin/env bash
set -eo pipefail

cluster_name=$1
export AWS_REGION=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)
efs_eks_cis_storage_id=$(op read op://my-vault/$cluster_name/eks-efs-csi-storage-id)

# create efs dynamic persistent volume claim
cat <<EOF > test/efs/dynamic-volume/pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
  namespace: test-system
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: $cluster_name-efs-csi-dynamic-storage
  resources:
    requests:
      storage: 5Gi
EOF
kubectl apply -f test/efs/dynamic-volume/pvc.yaml
kubectl apply -f test/efs/dynamic-volume/dynamic-volume-test-pod.yaml

# test efs dynamic persistent volume claim
sleep 30
bats test/efs/dynamic-volume/dynamic-volume-test.bats
kubectl delete -f test/efs/dynamic-volume/dynamic-volume-test-pod.yaml
kubectl delete -f test/efs/dynamic-volume/pvc.yaml

# test multi-write volume
cat <<EOF > test/efs/multi-write/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
  namespace: test-system
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: $cluster_name-efs-csi-dynamic-storage
  resources:
    requests:
      storage: 5Gi

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
  namespace: test-system
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: $cluster_name-efs-csi-dynamic-storage
  csi:
    driver: efs.csi.aws.com
    volumeHandle: $efs_eks_cis_storage_id
EOF
kubectl apply -f test/efs/multi-write/pvc.yaml
kubectl apply -f test/efs/multi-write/multi-write-test-pods.yaml
sleep 30
bats test/efs/multi-write/multi-write-test.bats

kubectl delete -f test/efs/multi-write/multi-write-test-pods.yaml
kubectl delete -f test/efs/multi-write/pvc.yaml
