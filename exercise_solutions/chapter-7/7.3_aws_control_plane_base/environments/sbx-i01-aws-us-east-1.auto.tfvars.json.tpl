{
  "cluster_name": "sbx-i01-aws-us-east-1",
  "aws_account_id": "{{ op://my-vault/aws-account-2/aws-account-id }}",
  "aws_assume_role": "Platform/Roles/PlatformControlPlaneBaseRole",
  "aws_region": "us-east-1",

  "eks_version": "1.32",
  "enable_log_types": ["api","audit","authenticator","controllerManager","scheduler"],
  "node_subnet_identifier": "node",
  "intra_subnet_identifier": "intra",

  "auto_refresh_management_node_group": "true",
  "management_node_group_name": "management-arm-rkt-mng",
  "management_node_group_role": "management",
  "management_node_group_ami_type": "BOTTLEROCKET_ARM_64",
  "management_node_group_disk_size": "50",
  "management_node_group_capacity_type": "SPOT",
  "management_node_group_desired_size": "1",
  "management_node_group_max_size": "3",
  "management_node_group_min_size": "1",
  "management_node_group_instance_types": ["t4g.2xlarge","m6g.2xlarge","m7g.2xlarge","m8g.2xlarge"],

  "karpenter_chart_version": "1.4.0",

  "oidc_client_id": "{{ op://my-vault/svc-auth0/dev-epectl-cli-client-id }}",
  "oidc_groups_claim": "https://github.org/epetech/teams",
  "oidc_identity_provider_config_name": "Auth0",
  "oidc_issuer_url": "https://dev-epectl.us.auth0.com/"
}
