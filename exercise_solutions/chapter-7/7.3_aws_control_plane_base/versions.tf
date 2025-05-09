terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "epetech"
    workspaces {
      prefix = "aws-control-plane-base-"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
    session_name = "aws-control-plane-base"
  }

  default_tags {
    tags = {
      pipeline                                    = "aws-control-plane-base"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--role", "arn:aws:iam::${var.aws_account_id}:role/${var.aws_assume_role}", "--region", var.aws_region]
    }
  }
}
