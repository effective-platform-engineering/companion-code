### **Exercise 8.2: Run Trivy scan on metrics-server chart and create a values.yaml to correct the findings**

(insert here a copy of the results of a trivy scan of the community metrics-server chart)
Customizations to add to the metrics-server deployment: 
image:
  pullPolicy: Always

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 65534
  runAsGroup: 65534
  seccompProfile:
    type: RuntimeDefault

updateStrategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1

podDisruptionBudget:
  enabled: true
  maxUnavailable: 1

resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 200m
    memory: 250Mi
