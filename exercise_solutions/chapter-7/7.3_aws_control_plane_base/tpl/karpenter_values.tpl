serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${iam_role_arn}
imagePullPolicy: Always
podDisruptionBudget:
  maxUnavailable: 1
replicas: 1
nodeSelector:
  nodegroup: ${management_node_group_name}
tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "${management_node_group_role}"
    effect: "NoSchedule"
settings:
  clusterName: ${cluster_name}
  clusterEndpoint: ${cluster_endpoint}
  interruptionQueue: ${queue_name}
  featureGates:
    drift: true
    spotToSpotConsolidation: true