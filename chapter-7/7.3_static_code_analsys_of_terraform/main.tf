
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name     = "main"
    Pipeline = "https://github.com/my-org-name/my-repo-name"
  }
}

resource "aws_security_group_rule" "my_sg_rule" {
  description       = "example sg rule"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = "sg-123456"
}

# terraform fmt will correct spacing
# terraform validate will catch cidr syntax

# tflint will catch
# Warning: terraform "required_version" attribute is required (terraform_required_version)
# Warning: Missing version constraint for provider "aws" in "required_providers" (terraform_required_providers)
# Warning: Module should include an empty outputs.tf file (terraform_standard_module_structure)
# Warning: Module should include an empty variables.tf file (terraform_standard_module_structure)
