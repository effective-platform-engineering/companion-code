
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0"
  tags = {
    Name = "main"
    Pipeline = "https://github.com/my-org-name/my-repo-name"
  }
}

resource "aws_security_group_rule" "my_sg_rule" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "sg-123456"
}
