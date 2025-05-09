module "eks_addons" {
  source     = "aws-ia/eks-blueprints-addons/aws"
  version    = "1.21.0"
  depends_on = [module.eks]

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {

    kube-proxy = { most_recent = true }

    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
    }

    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        autoScaling = {
          "enabled" = true
        }
        nodeSelector = {
          "node.kubernetes.io/role" = "management"
        }
        tolerations = [
          {
            key      = "dedicated"
            operator = "Equal"
            value    = "management"
            effect   = "NoSchedule"
          }
        ]
      })
    }

    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      configuration_values = jsonencode({
        controller = {
          nodeSelector = {
            "node.kubernetes.io/role" = "management"
          }
          tolerations = [
            {
              key      = "dedicated"
              operator = "Equal"
              value    = "management"
              effect   = "NoSchedule"
            }
          ]
        }
      })
    }

    aws-efs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.efs_csi_irsa_role.iam_role_arn
      configuration_values = jsonencode({
        controller = {
          nodeSelector = {
            "node.kubernetes.io/role" = "management"
          }
          tolerations = [
            {
              key      = "dedicated"
              operator = "Equal"
              value    = "management"
              effect   = "NoSchedule"
            }
          ]
        }
      })
    }

    eks-pod-identity-agent = { most_recent = true }
  }
}

module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.55.0"

  role_path             = "/PlatformRoles/"
  role_name             = "${var.cluster_name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.55.0"

  role_path             = "/PlatformRoles/"
  role_name             = "${var.cluster_name}-ebs-csi-controller-sa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "efs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.55.0"

  role_path             = "/PlatformRoles/"
  role_name             = "${var.cluster_name}-efs-csi-controller-sa"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}
