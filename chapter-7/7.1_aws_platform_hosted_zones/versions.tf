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
      prefix = "aws-platform-hosted-zones-"
    }
  }
}
