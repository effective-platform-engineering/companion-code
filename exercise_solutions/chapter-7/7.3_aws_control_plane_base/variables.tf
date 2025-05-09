variable "aws_region" {
  type = string
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "Invalid AWS Region name."
  }
}

variable "aws_account_id" {
  type = string
  validation {
    condition     = length(var.aws_account_id) == 12 && can(regex("^\\d{12}$", var.aws_account_id))
    error_message = "Invalid AWS account ID"
  }
}

variable "aws_assume_role" { type = string }

variable "cluster_name" {
  description = "cluster instance name"
  type        = string
}

variable "enable_log_types" {
  description = "list of control plane log types to be generated"
  type        = list(string)
}

variable "eks_version" {
  description = "EKS-kubernetes control plane version"
  type        = string

  validation {
    condition     = can(regex("^1.[2-3][0-9]$", var.eks_version))
    error_message = "Invalid EKS version number"
  }
}

variable "node_subnet_identifier" {
  description = "search string to identity node pool subnets"
  type        = string
}

variable "intra_subnet_identifier" {
  description = "search string to identity intra pool subnets"
  type        = string
}

variable "management_node_group_name" {
  type = string
  validation {
    condition     = (length(var.management_node_group_name) < 63)
    error_message = "Invalid node group name. Must be less than 63 characters."
  }
}

variable "management_node_group_role" {
  type = string
  validation {
    condition     = (length(var.management_node_group_role) < 128)
    error_message = "Invalid node group role name. Must be less than 128 characters."
  }
}

variable "management_node_group_ami_type" {
  type = string
  validation {
    condition     = contains(["AL2_x86_64", "BOTTLEROCKET_x86_64", "AL2_ARM_64", "BOTTLEROCKET_ARM_64"], var.management_node_group_ami_type)
    error_message = "Invalid AMI Type. Use AL2_x86_64 | BOTTLEROCKET_x86_64 | AL2_ARM_64 | BOTTLEROCKET_ARM_64"
  }
}

variable "management_node_group_disk_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]$", var.management_node_group_disk_size))
    error_message = "Invalid node disk size. Use value between 10 to 99gb."
  }
}

variable "management_node_group_capacity_type" {
  type = string
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.management_node_group_capacity_type)
    error_message = "Invalid capacity Type. Use ON_DEMAND | SPOT"
  }
}

variable "management_node_group_desired_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]{0,2}$", var.management_node_group_desired_size))
    error_message = "Invalid desired node group size. Must be number beween 1-999"
  }
}

variable "management_node_group_max_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]{0,2}$", var.management_node_group_max_size))
    error_message = "Invalid max node group size. Must be number beween 1-999"
  }
}

variable "management_node_group_min_size" {
  type = string
  validation {
    condition     = can(regex("^[1-9][0-9]{0,2}$", var.management_node_group_min_size))
    error_message = "Invalid min node group size. Must be number beween 1-999"
  }
}

variable "management_node_group_instance_types" {
  description = "list of allowable ec2 instance types"
  type        = list(string)
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version to be installed"
  type        = string
}

variable "oidc_client_id" {
  description = "Auth0 client id"
  type        = string
  sensitive   = true
}

variable "oidc_groups_claim" {
  description = "authorization claim from jwt token"
  type        = string
}

variable "oidc_identity_provider_config_name" {
  description = "oidc provider name"
  type        = string
}

variable "oidc_issuer_url" {
  description = "oidc client url"
  type        = string
}