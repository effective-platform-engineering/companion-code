# Throughout main.tf you will see var.is_state_account used to determine whether or not
# the configuration should be applied. Service accounts, groups, and group memberships are defined
# only in the state account. Roles are applied to all accounts. Group membership determines in
# which accounts the identity may assume a role.

# Non-production service account identity ===============================================
# For assuming roles in non-production and also non-customer facing environments. A separate pipeline step
# will create and store the service account credentials in the secrets store

module "NonprodServiceAccount" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.48.0"

  create_user                   = var.is_state_account
  name                          = "NonprodServiceAccount"
  path                          = "/ServiceAccounts/"
  create_iam_access_key         = false
  create_iam_user_login_profile = false
  force_destroy                 = true
  password_reset_required       = false
}

module "NonprodServiceAccountGroup" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "5.48.0"

  count           = var.is_state_account ? 1 : 0
  name            = "NonprodServiceAccountGroup"
  path            = "/Groups/"
  assumable_roles = var.all_nonprod_account_roles

  # include the nonprod service account in the nonprod group
  group_users = [
    module.NonprodServiceAccount.iam_user_name
  ]
}

# Production service account identity ====================================================
# For assuming roles in all environments (including customer facing). A separate pipeline step
# will create and store the service account credentials in the secrets store

module "ProdServiceAccount" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.48.0"

  create_user                   = var.is_state_account
  name                          = "ProdServiceAccount"
  path                          = "/ServiceAccounts/"
  create_iam_access_key         = false
  create_iam_user_login_profile = false
  force_destroy                 = true
  password_reset_required       = false
}

module "ProdServiceAccountGroup" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"
  version = "5.48.0"

  count           = var.is_state_account ? 1 : 0
  name            = "ProdServiceAccountGroup"
  path            = "/Groups/"
  assumable_roles = concat(var.all_nonprod_account_roles, var.all_production_account_roles)

  # include the production service account in the production group
  group_users = [
    module.ProdServiceAccount.iam_user_name
  ]
}
