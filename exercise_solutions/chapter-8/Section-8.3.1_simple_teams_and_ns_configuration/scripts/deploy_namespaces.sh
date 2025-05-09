#!/usr/bin/env bash
set -eo pipefail

export cluster_name=$1
export registryaccess=$2

# Load the simple sample teams data for the current cluster
json_file=environments/$cluster_name-teams.json

# Read the list of teams
teams=$(jq -r 'keys[]' $json_file)

# Iterate over each team
echo "generate $cluster_name team namespace resource files"
for team in $teams; do
  echo "team: $team"

  # Read the namespaces that should exist for the current team
  namespaces=$(jq -r --arg k "$team" '.[$k][]' $json_file)

  # Iterate over each namespace
  for namespace in $namespaces; do
    echo "  namespace: $namespace"

    cat <<EOF > ns/$team-$namespace-resources.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: $team-$namespace
  labels:
    istio-injection: enabled
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/enforce: baseline

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: $team-$namespace-ns-quota
  namespace: $team-$namespace
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "10"
    limits.memory: 20Gi

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $team-$namespace-team-role
  namespace: $team-$namespace
rules:
  - apiGroups: ["*"]
    resources:
      - configmaps
      - cronjobs
      - deployments
      - endpoints
      - events
      - horizontalpodautoscalers
      - jobs
      - leases
      - limitranges
      - namespaces
      - networkpolicies
      - nodes
      - nodeclaims
      - persistentvolumeclaims
      - persistentvolumes
      - poddisruptionbudgets
      - pods
      - replicasets
      - replicationcontrollers
      - resourcequotas
      - services
      - statefulsets
      - storageclasses
      - validatingwebhookconfigurations
      - volumeattachments
    verbs: ["get", "watch", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $team-$namespace-team-rolebinding
  namespace: $team-$namespace
subjects:
  - kind: Group
    name: epetech/$team
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: $team-$namespace-team-role
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: v1
kind: Secret
metadata:
  name: regcred
  namespace: $team-$namespace
data:
  .dockerconfigjson: $registryaccess
type: kubernetes.io/dockerconfigjson
EOF

  done
done

echo "deploy resources"
kubectl apply -f ns --recursive