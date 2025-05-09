## ***Exercise 4.3: Create an admission controller policy to allow only images from our registry and organization***

Let’s try another admission policy. In the earlier example, the input data from the deployment shows that we are using the GitHub container registry. Create a rego policy that only allows deployments from our organization (ghcr.io/epetech).

### **Solution**