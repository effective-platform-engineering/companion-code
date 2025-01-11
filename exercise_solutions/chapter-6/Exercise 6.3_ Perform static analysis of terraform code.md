### **Exercise 6.3: Perform static analysis of terraform code**

Create a file called main.tf with the following contents.

resource "aws\_vpc" "main" {  
  cidr\_block \= "10.0.0.0"  
  tags \= {  
    Name \= "main"  
    Pipeline \= "[https://github.com/my-org-name/my-repo-name](https://github.com/my-org-name/my-repo-name)"  
  }  
}

resource "aws\_security\_group\_rule" "my\_sg\_rule" {  
  type \= "ingress"  
  from\_port \= 0  
  to\_port \= 65535  
  protocol \= "tcp"  
  cidr\_blocks \= \["0.0.0.0/0"\]  
  security\_group\_id \= "sg-123456"  
}

1. Using the Terraform CLI, validate the syntax and canonical formatting of main.tf  
2. Correct the error and re-run the test  
3. Using the Terraform CLI, apply canonical formatting to main.tf  
4. Using Tflint, check the code style and formatting for best practices  
5. Make the recommended changes until Tflint no longer returns warnings  
6. Run a Trivy scan main.tf  
7. Finally, correct the security issues in main.tf. For the MEDIUM alert, rather than adding a VPC Flow Log configuration, research the Trivy documentation for instructions on how to add an inline comment to ignore that particular security check. 

Before we leave the topic, let’s implement the local git commit-hooks recommendation from \#G in Diagram 6-7. The Python package pre-commit[^1] is an effective utility for managing local git commit hooks. Like the integration tests, the static analysis scans we examined above are steps that we want to include in our CI pipeline. Static tests can be applied locally against changed files with each commit for faster feedback rather than waiting for the pipeline to fail.

In the typical Terraform pipeline, an effective commit scan will include:

1. Static code analysis scans (same as will be applied in the pipeline)[^2]  
2. Scan for secrets inadvertently committed[^3]  
3. Basic git syntax and configuration standards[^4]  
4. Basic syntax scans for structured file types commonly found in Terraform repos

### **Solution**

Using the Terraform CLI, validate the syntax and canonical formatting of main.tf

Solution:

$ terraform init  
$ terraform validate . 

Error: expected cidr\_block to contain a valid Value, got: 10.0.0.0 with err: invalid CIDR address: 10.0.0.0  
…

Correct the error and re-run the test.

Using the Terraform CLI, apply canonical formatting to main.tf

Solution:

$ terraform fmt

$ cat main.tf

resource "aws\_vpc" "main" {  
  cidr\_block \= "10.0.0.0/16"  
  tags \= {  
    Name     \= "main"                                         \#A  
    Pipeline \= "[https://github.com/my-org-name/my-repo-name](https://github.com/my-org-name/my-repo-name)"  
  }  
}

resource "aws\_security\_group\_rule" "my\_sg\_rule" {  
  type              \= "ingress"  
  from\_port         \= 0  
  to\_port           \= 65535  
  protocol          \= "tcp"  
  cidr\_blocks       \= \["0.0.0.0/0"\]  
  security\_group\_id \= "sg-123456"  
}

**\#A** Notice how the file has been changed so that the assignment characters (“=”) are now aligned vertically.

Using Tflint, check the code style and formatting for best practices.

Solution.

$ tflint

...  
Warning: terraform "required\_version" attribute is required (terraform\_required\_version)

...

Warning: Missing version constraint for provider "aws" in "required\_providers" 

...

Make the recommended changes until Tflint no longer returns warnings.

Finally, run a Trivy scan against main.tf

$ trivy config main.tf

...

CRITICAL: Security group rule allows ingress from public internet.  
...

MEDIUM: VPC Flow Logs is not enabled for VPC  
...

LOW: Security group rule does not have a description.  
...

Correct the security issues in main.tf. For the MEDIUM alert, rather than adding a VPC Flow Log configuration, research the Trivy documentation for instructions on how to add an inline comment to ignore that particular security check.

[^1]:  https://pre-commit.com/

[^2]:  https://github.com/antonbabenko/pre-commit-terraform

[^3]:  https://github.com/awslabs/git-secrets

[^4]:  https://github.com/pre-commit/pre-commit-hooks