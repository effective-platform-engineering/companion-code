{
  "aws_account_id": "{{ op://my-vault/aws-account-1/aws-account-id }}",
  "aws_assume_role": "PlatformRoles/PlatformControlPlaneBaseRole",
  "aws_region": "us-east-2",
  "cluster_name": "prod-i01-aws-us-east-2",
  "cert_manager_chart_version": "1.17.1",
  "external_dns_chart_version": "1.16.0",
  "istio_version": "1.25.1",

  "cluster_domains": [
    "epetech.io",
    "prod-i01-aws-us-east-2.epetech.io"
  ],
  "issuerEndpoint": "https://acme-v02.api.letsencrypt.org/directory",
  "issuerEmail": "owner@epetech.io"
}