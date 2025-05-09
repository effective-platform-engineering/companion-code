locals {
  domain_epetech_io = "epetech.io"
}

provider "aws" {
  alias  = "domain_epetech_io"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/${var.assume_role}"
  }
}

# zone id for the top-level-zone
data "aws_route53_zone" "zone_id_epetech_io" {
  provider = aws.domain_epetech_io
  name     = local.domain_epetech_io
}
