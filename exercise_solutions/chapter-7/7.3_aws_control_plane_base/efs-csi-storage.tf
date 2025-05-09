module "efs_csi_storage" {
  source  = "cloudposse/efs/aws"
  version = "1.1.0"

  name = "${var.cluster_name}-efs-csi-storage"

  region  = var.aws_region
  vpc_id  = data.aws_vpc.vpc.id
  subnets = data.aws_subnets.cluster_private_subnets.ids

  allowed_cidr_blocks           = [for s in data.aws_subnet.cluster_private_subnets : s.cidr_block]
  associated_security_group_ids = [module.eks.cluster_security_group_id]

  transition_to_ia          = ["AFTER_7_DAYS"]
  efs_backup_policy_enabled = true
  encrypted                 = true

  tags = {
    "cluster"  = var.cluster_name
    "pipeline" = "aws-control-plane-base"
  }
}

output "eks_efs_csi_storage_dns_name" {
  value = module.efs_csi_storage.dns_name
}

output "eks_efs_csi_storage_id" {
  value = module.efs_csi_storage.id
}

output "eks_efs_csi_storage_mount_target_dns_names" {
  value = module.efs_csi_storage.mount_target_dns_names
}

output "eks_efs_csi_storage_security_group_id" {
  value = module.efs_csi_storage.security_group_id
}