locals {
  domain_vitalsigns_io = "vitalsigns.io"
}

provider "aws" {
  alias  = "domain_vitalsigns_io"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/${var.assume_role}"
  }
}

# zone id for the top-level-zone
data "aws_route53_zone" "zone_id_vitalsigns_io" {
  provider = aws.domain_vitalsigns_io
  name     = local.domain_vitalsigns_io
}
