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
  sensitive = true
}

variable "aws_assume_role" { type = string }
variable "cluster_name" { type = string }
