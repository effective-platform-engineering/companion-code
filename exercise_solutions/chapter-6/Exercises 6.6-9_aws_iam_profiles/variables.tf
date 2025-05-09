
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

variable "is_state_account" {
  description = "create STATE account configuration?"
  type        = bool
  default     = false
}

variable "state_account_id" {
  description = "arn principal root reference to state account id where all svc accounts are defined"
  type        = string
  validation {
    condition     = length(var.state_account_id) == 12 && can(regex("^\\d{12}$", var.state_account_id))
    error_message = "Invalid AWS account ID"
  }
}

variable "all_nonprod_account_roles" {
  description = "arn reference to * roles for all non-production aws accounts; arn:aws:iam::*****12345:role/*"
  type        = list(any)
}

variable "all_production_account_roles" {
  description = "arn reference to * roles for all production aws accounts; arn:aws:iam::*****12345:role/*"
  type        = list(any)
}
