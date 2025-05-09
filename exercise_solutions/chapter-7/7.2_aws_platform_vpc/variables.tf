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

variable "vpc_cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 32))
    error_message = "Invalid IPv4 CIDR"
  }
}

variable "vpc_azs" {
  description = "list of subnet AZs"
  type        = list(string)

  validation {
    condition = alltrue([
      for v in var.vpc_azs : can(regex("[a-z][a-z]-[a-z]+-[1-9][a-c]", v))
    ])
    error_message = "Invalid VPC AZ name"
  }

  validation {
    condition     = length(var.vpc_azs) == 3
    error_message = "length of list(string) not equal to 3 "
  }
}

variable "vpc_private_subnets" {
  description = "private node group subnet"
  type        = list(string)

  validation {
    condition = alltrue([
      for v in var.vpc_private_subnets : can(cidrhost(v, 32))
    ])
    error_message = "Invalid IPv4 CIDR"
  }

  validation {
    condition     = length(var.vpc_private_subnets) == 3
    error_message = "length of list(string) not equal to 3 "
  }
}

variable "vpc_intra_subnets" {
  description = "intra subnet"
  type        = list(string)

  validation {
    condition = alltrue([
      for v in var.vpc_intra_subnets : can(cidrhost(v, 32))
    ])
    error_message = "Invalid IPv4 CIDR"
  }

  validation {
    condition     = length(var.vpc_intra_subnets) == 3
    error_message = "length of list(string) not equal to 3 "
  }
}

variable "vpc_public_subnets" {
  description = "public ingress load balancer subnet"
  type        = list(string)

  validation {
    condition = alltrue([
      for v in var.vpc_public_subnets : can(cidrhost(v, 32))
    ])
    error_message = "Invalid IPv4 CIDR"
  }

  validation {
    condition     = length(var.vpc_public_subnets) == 3
    error_message = "length of list(string) not equal to 3 "
  }
}

variable "vpc_database_subnets" {
  description = "private database subnet"
  type        = list(string)

  validation {
    condition = alltrue([
      for v in var.vpc_database_subnets : can(cidrhost(v, 32))
    ])
    error_message = "Invalid IPv4 CIDR"
  }

  validation {
    condition     = length(var.vpc_database_subnets) == 3
    error_message = "length of list(string) not equal to 3 "
  }
}
