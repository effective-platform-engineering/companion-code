{
  "aws_account_id": "{{ op://my-vault/aws-account-2/aws-account-id }}",
  "aws_assume_role": "PlatformRoles/PlatformControlPlaneBaseRole",
  "aws_region": "us-east-1",
  "cluster_name": "sbx-i01-aws-us-east-1",
  "cert_manager_chart_version": "1.17.1",
  "external_dns_chart_version": "1.16.0",
  "istio_version": "1.25.1",

  "cluster_domains": [
    "sbx-i01-aws-us-east-1.epetech.io"
  ],
  "issuerEndpoint": "https://acme-v02.api.letsencrypt.org/directory",
  "issuerEmail": "owner@epetech.io"
}