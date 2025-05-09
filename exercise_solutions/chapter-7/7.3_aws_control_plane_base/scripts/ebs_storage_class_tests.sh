#!/usr/bin/env bash
set -eo pipefail

cluster_name=$1
export AWS_REGION=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)

# create ebs-csi dynamic persistent volume claim
cat <<EOF > test/ebs/dynamic-volume/pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-ebs-claim
  namespace: test-system
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: $cluster_name-ebs-csi-dynamic-storage
  resources:
    requests:
      storage: 4Gi
EOF
kubectl apply -f test/ebs/dynamic-volume/pvc.yaml

# test persistent volume claim
kubectl apply -f test/ebs/dynamic-volume/dynamic-volume-test-pod.yaml
sleep 30
bats test/ebs/dynamic-volume/initial-pvc-test.bats

# expand dynamic volume size
cat <<EOF > test/ebs/dynamic-volume/pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-ebs-claim
  namespace: test-system
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: $cluster_name-ebs-csi-dynamic-storage
  resources:
    requests:
      storage: 8Gi
EOF
kubectl apply -f test/ebs/dynamic-volume/pvc.yaml

# test expanded persistent volume claim
sleep 90
bats test/ebs/dynamic-volume/expanded-pvc-test.bats

kubectl delete -f test/ebs/dynamic-volume/dynamic-volume-test-pod.yaml
kubectl delete -f test/ebs/dynamic-volume/pvc.yaml
