{
  "cluster_name": "prod-i01-aws-us-east-2",
  "aws_account_id": "{{ op://my-vault/aws-account-1/aws-account-id }}",
  "aws_assume_role": "Roles/PlatformVPCRole",
  "aws_region": "us-east-2",
  "vpc_cidr": "10.90.0.0/16",
  "vpc_azs": [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ],
  "vpc_private_subnets": [
    "10.90.0.0/18",
    "10.90.64.0/18",
    "10.90.128.0/18"
  ],
  "vpc_intra_subnets": [
    "10.90.192.0/20",
    "10.90.208.0/20",
    "10.90.224.0/20"
  ],
  "vpc_database_subnets": [
    "10.90.240.0/23",
    "10.90.242.0/23",
    "10.90.244.0/23"
  ],
  "vpc_public_subnets": [
    "10.90.246.0/23",
    "10.90.248.0/23",
    "10.90.250.0/23"
  ]
}
