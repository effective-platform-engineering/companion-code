terraform {
  required_version = "~> 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78"
    }
  }

  # Remote backend state using terraform cloud
  # Note: the `prefix` workspace configuration creates a separate state store for
  # each environment. These must be pre-created using the terraform cli. In addition,
  # after creating a workspace you must access the app.terraform.io UI and set the
  # workspace to type `local`.
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my-org"
    workspaces {
      prefix = "platform-iam-profiles-"
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
    session_name = "platform-iam-profiles"
  }

  default_tags {
    tags = {
      product  = "engineering platform"
      pipeline = "platform-iam-profiles"
    }
  }
}
