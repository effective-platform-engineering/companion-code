{
  "aws_account_id": "{{ op://my-vault/aws-account-1/aws-account-id }}",
  "aws_assume_role": "PlatformRoles/PlatformControlPlaneBaseRole",
  "aws_region": "us-east-2",
  "cluster_name": "prod-i01-aws-us-east-2",
  "external_dns_chart_version": "1.16.0",

  "cluster_domains": [
    "dev.epetech.io",
    "qa.epetech.io",
    "api.epetech.io"
  ],
  "issuerEndpoint": "https://acme-v02.api.letsencrypt.org/directory",
  "issuerEmail": "owner@epetech.io"
}