terraform {
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my-org"
    workspaces {
      prefix = "aws-platform-vpc-"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
    session_name = "aws-platform-vpc-${var.cluster_name}"
  }

  default_tags {
    tags = {
      env      = var.cluster_name
      cluster  = var.cluster_name
      pipeline = "aws-platform-vpc"
    }
  }
}
