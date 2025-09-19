### **Exercise 8.2: Run Trivy scan on metrics-server chart and create a values.yaml to correct the findings**

Trivy will report a few security best-practices something like the following:  

```bash
AVD-KSV-0011 (LOW): Container 'metrics-server' of Deployment 'metrics-server' should set 'resources.limits.cpu'
Enforcing CPU limits prevents DoS via resource exhaustion.

See https://avd.aquasec.com/misconfig/ksv011
 templates/deployment.yaml:28-73
  28 ┌         - name: metrics-server
  29 │           securityContext:
  30 │             allowPrivilegeEscalation: false
  31 │             capabilities:
  32 │               drop:
  33 │               - ALL
  34 │             readOnlyRootFilesystem: true
  35 │             runAsNonRoot: true
  36 └             runAsUser: 1000
  ..

AVD-KSV-0018 (LOW): Container 'metrics-server' of Deployment 'metrics-server' should set 'resources.limits.memory'
Enforcing memory limits prevents DoS via resource exhaustion.

See https://avd.aquasec.com/misconfig/ksv018
 templates/deployment.yaml:28-73
  28 ┌         - name: metrics-server
  29 │           securityContext:
  30 │             allowPrivilegeEscalation: false
  31 │             capabilities:
  32 │               drop:
  33 │               - ALL
  34 │             readOnlyRootFilesystem: true
  35 │             runAsNonRoot: true
  36 └             runAsUser: 1000
  ..


AVD-KSV-0020 (LOW): Container 'metrics-server' of Deployment 'metrics-server' should set 'securityContext.runAsUser' > 10000
Force the container to run with user ID > 10000 to avoid conflicts with the host’s user table.

See https://avd.aquasec.com/misconfig/ksv020
 templates/deployment.yaml:28-73
  28 ┌         - name: metrics-server
  29 │           securityContext:
  30 │             allowPrivilegeEscalation: false
  31 │             capabilities:
  32 │               drop:
  33 │               - ALL
  34 │             readOnlyRootFilesystem: true
  35 │             runAsNonRoot: true
  36 └             runAsUser: 1000
  ..


AVD-KSV-0021 (LOW): Container 'metrics-server' of Deployment 'metrics-server' should set 'securityContext.runAsGroup' > 10000
Force the container to run with group ID > 10000 to avoid conflicts with the host’s user table.

See https://avd.aquasec.com/misconfig/ksv021
 templates/deployment.yaml:28-73
  28 ┌         - name: metrics-server
  29 │           securityContext:
  30 │             allowPrivilegeEscalation: false
  31 │             capabilities:
  32 │               drop:
  33 │               - ALL
  34 │             readOnlyRootFilesystem: true
  35 │             runAsNonRoot: true
  36 └             runAsUser: 1000
  ..


AVD-KSV-0118 (HIGH): deployment metrics-server in null namespace is using the default security context, which allows root privileges
Security context controls the allocation of security parameters for the pod/container/volume, ensuring the appropriate level of protection. Relying on default security context may expose vulnerabilities to potential attacks that rely on privileged access.

See https://avd.aquasec.com/misconfig/ksv118
 templates/deployment.yaml:25-76
  25 ┌       serviceAccountName: metrics-server
  26 │       priorityClassName: "system-cluster-critical"
  27 │       containers:
  28 │         - name: metrics-server
  29 │           securityContext:
  30 │             allowPrivilegeEscalation: false
  31 │             capabilities:
  32 │               drop:
  33 └               - ALL
  ..


AVD-KSV-0125 (MEDIUM): Container metrics-server in deployment metrics-server (namespace: null) uses an image from an untrusted registry.
Ensure that all containers use images only from trusted registry domains.

See https://avd.aquasec.com/misconfig/ksv0125
 templates/deployment.yaml:28-73
  28 ┌         - name: metrics-server
  29 │           securityContext:
  30 │             allowPrivilegeEscalation: false
  31 │             capabilities:
  32 │               drop:
  33 │               - ALL
  34 │             readOnlyRootFilesystem: true
  35 │             runAsNonRoot: true
  36 └             runAsUser: 1000
  ..
```

Add these customizations to add to the metrics-server deployment to adopt the recommendations: 
```yaml
# pod configuration addition
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

# container resources
image:
  pullPolicy: Always

resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 200m
    memory: 250Mi
```