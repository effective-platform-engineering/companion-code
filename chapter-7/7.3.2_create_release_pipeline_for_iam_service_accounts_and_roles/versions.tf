
terraform {
  # pin major.minor versions
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
  }

  # Remote backend state using terraform cloud
  # Note: the `prefix` workspace configuration creates a separate state store for
  # each environment.
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my_terraform_cloud_org"
    workspaces {
      prefix = "iam-profiles-"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # this section commented out during the initial bootstrap run.
  # once the assumeable roles are created, uncomment and change
  # op.*.env to contain the appropriate service account identity
  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
    session_name = "iam-profiles"
  }

  default_tags {
    tags = {
      product  = "empc engineering platform"
      pipeline = "iam-profiles"
    }
  }
}
