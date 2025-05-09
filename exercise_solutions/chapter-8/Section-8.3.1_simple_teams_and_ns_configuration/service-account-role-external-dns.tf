data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

module "external_dns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.55.0"

  role_path                  = "/PlatformRoles/"
  role_name                  = "simple-teams-external-dns-sa"
  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["istio-system:simple-teams-external-dns"]
    }
  }
}
