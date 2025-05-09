terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "epetech"
    workspaces {
      prefix = "aws-control-plane-extensions-"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
    session_name = "aws-control-plane-extensions"
  }

  default_tags {
    tags = {
      pipeline                                    = "aws-control-plane-extensions"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  }
}
