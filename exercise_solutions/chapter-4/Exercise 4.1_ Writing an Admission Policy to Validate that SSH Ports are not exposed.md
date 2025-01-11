## ***Exercise 4.1: Writing an Admission Policy to Validate that SSH Ports are not exposed***

Taking what you have learned so far, write a Kubernetes Admission policy that does something very practical: write an admission policy that looks at all of the exposed ports for deployment and makes sure that deployment isn’t trying to expose an SSH port. When you write this policy(s), consider what Kubernetes objects you need to verify in your admission controllers. Hint: it’s not just the Pod you need to work about\!

### **Solution**