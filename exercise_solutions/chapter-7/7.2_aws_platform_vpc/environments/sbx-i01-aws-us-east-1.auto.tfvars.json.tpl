{
  "cluster_name": "sbx-i01-aws-us-east-1",
  "aws_account_id": "{{ op://my-vault/aws-account-2/aws-account-id }}",
  "aws_assume_role": "Roles/PlatformVPCRole",
  "aws_region": "us-east-1",
  "vpc_cidr": "10.80.0.0/16",
  "vpc_azs": [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ],
  "vpc_private_subnets": [
    "10.80.0.0/18",
    "10.80.64.0/18",
    "10.80.128.0/18"
  ],
  "vpc_intra_subnets": [
    "10.80.192.0/20",
    "10.80.208.0/20",
    "10.80.224.0/20"
  ],
  "vpc_database_subnets": [
    "10.80.240.0/23",
    "10.80.242.0/23",
    "10.80.244.0/23"
  ],
  "vpc_public_subnets": [
    "10.80.246.0/23",
    "10.80.248.0/23",
    "10.80.250.0/23"
  ]
}
