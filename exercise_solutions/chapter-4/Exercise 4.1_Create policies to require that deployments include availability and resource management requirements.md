## ***Exercise 4.1: Create policies to require that deployments include availability and resource management requirements***

In the above example, our code coverage requirements are being verified with each deployment. Now let’s expand on that policy. Assume that two more requirements have been identified.
Deployments must have more than a single replica defined to provide availability.
Deployments must have resource limits and requests defined to support improved resource management.  

Using all the elements from the code coverage example (data, input, and policy), add the additional policy language that will apply these additional requirements. You can include statements like the following print statement within rego rule statements (the body of the if {...statements} function-like definitions) . The output will appear in the browser developers Console window.

### **Solution**
Assuming INPUT includes:  

{
  "kind": "AdmissionReview",
  "apiVersion": "admission.k8s.io/v1",
  "request": {
    "kind": {
      "group": "apps",
      "version": "v1",
      "kind": "Deployment"
    },
    "name": "my-app",
    "namespace": "my-team-dev",
    "operation": "CREATE",
    "object": {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
        "name": "my-app",
        "namespace": "my-team-dev",
        "source-sha": "bc183a62",
        "labels": {
          "app": "my-app"
        }
      },
      "spec": {
        "replicas": 3,
        "selector": {
          "matchLabels": {
            "app": "my-app"
          }
        },
        "template": {
          "metadata": {
            "labels": {
              "app": "my-app"
            }
          },
          "spec": {
            "containers": [
              {
                "name": "my-app",
                "image": "ghcr.io/epetech/my-app:v1.8.3",
                "resources": {
                  "limits": {
                    "cpu": "100m",
                    "memory": "256Mi"
                  },
                  "requests": {
                    "cpu": "100m",
                    "memory": "128Mi"
                  }
                }
              }
            ]
          }
        },
        "strategy": {
          "type": "RollingUpdate",
          "rollingUpdate": {
            "maxUnavailable": "25%",
            "maxSurge": "25%"
          }
        }
      }
    }
  }
}

Assume DATA response from our code coverage source includes:  

{
  “code_quality_attributes”: {
    “bc183a62”: { #A
       “issues”: “4”,
       “coverage”: 98,
       “complexity”: 5,
       “lines_of_code”: 3769
    }
  }
}

Then the additional policies could be written as:  

package test

default deny := false

deny if code_coverage_lt_required
deny if multiple_replicas_not_defined
deny if container_resource_limits_not_defined
deny if container_resource_requests_not_defined

code_coverage_lt_required if {
	print("sha to check", input.request.object.metadata.sha)
	print("results returned from data source", data.code_quality_attributes[input.request.object.metadata.sha].coverage)
	data.code_quality_attributes[input.request.object.metadata.sha].coverage < 80
}

multiple_replicas_not_defined if {
	print("replicas defined", input.request.object.spec.replicas)
	input.request.object.spec.replicas < 2
}

container_resource_limits_not_defined if {
	some container in input.request.object.spec.template.spec.containers
    print("container resource definition", container.resources)
	not container.resources.limits
}

container_resource_requests_not_defined if {
	some container in input.request.object.spec.template.spec.containers
    print("container resource definition", container.resources)
	not container.resources.requests
}
