variable "nonprod_account_id" {
  type      = string
  validation {
    condition     = length(var.nonprod_account_id) == 12 && can(regex("^\\d{12}$", var.nonprod_account_id))
    error_message = "Invalid AWS account ID"
  }
  sensitive = true
}

variable "prod_account_id" {
  type      = string
  validation {
    condition     = length(var.prod_account_id) == 12 && can(regex("^\\d{12}$", var.prod_account_id))
    error_message = "Invalid AWS account ID"
  }
  sensitive = true
}

variable "assume_role" { type = string }
