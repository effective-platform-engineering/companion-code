#trivy:ignore:AVD-AWS-0178
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
