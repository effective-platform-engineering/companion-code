
data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

data "aws_subnets" "cluster_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Tier = var.node_subnet_identifier
  }
}

data "aws_subnet" "cluster_private_subnets" {
  for_each = toset(data.aws_subnets.cluster_private_subnets.ids)
  id       = each.value
}

data "aws_subnets" "cluster_intra_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Tier = var.intra_subnet_identifier
  }
}