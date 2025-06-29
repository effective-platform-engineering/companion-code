## ***Exercise 4.3: Create an admission controller policy to allow only images from our registry and organization***

Let’s try another admission policy. In the earlier example, the input data from the deployment shows that we are using the GitHub container registry. Create a rego policy that only allows deployments from our organization (ghcr.io/epetech).

### **Solution**
``` rego
package test

default deny := false

deny if code_coverage_lt_required
deny if multiple_replicas_not_defined
deny if container_resource_limits_not_defined
deny if container_resource_requests_not_defined

code_coverage_lt_required if {
	sha = input.request.object.metadata["source-sha"]
	print("sha to check", sha)
	print("results returned from data source", data.code_quality_attributes[sha].coverage)
	data.code_quality_attributes[sha].coverage < 80
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

container_image_from_organization_repository_not_defined if {
	some container in input.request.object.spec.template.spec.containers
	print("container image definition", container.image)
	not regex.match(`^ghcr.io/epetech.*`, container.image)
}
```
