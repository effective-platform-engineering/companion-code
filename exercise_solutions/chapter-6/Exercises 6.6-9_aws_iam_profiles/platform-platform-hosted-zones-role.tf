
module "PlatformHostedZonesRole" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version     = "5.55.0"
  create_role = true

  role_name                         = "PlatformHostedZonesRole"
  role_path                         = "/Roles/"
  role_requires_mfa                 = false
  custom_role_policy_arns           = [aws_iam_policy.PlatformHostedZonesRolePolicy.arn]
  number_of_custom_role_policy_arns = 1

  trusted_role_arns = ["arn:aws:iam::${var.state_account_id}:root"]
}

# role permissions
resource "aws_iam_policy" "PlatformHostedZonesRolePolicy" {
  name = "PlatformHostedZonesRolePolicy"
  path = "/Policies/"

  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : [
          "route53:AcceptDomainTransferFromAnotherAwsAccount",
          "route53:AssociateVPCWithHostedZone",
          "route53:CancelDomainTransferToAnotherAwsAccount",
          "route53:ChangeCidrCollection",
          "route53:ChangeResourceRecordSets",
          "route53:ChangeTagsForResource",
          "route53:CreateCidrCollection",
          "route53:CreateHealthCheck",
          "route53:CreateHostedZone",
          "route53:CreateKeySigningKey",
          "route53:CreateReusableDelegationSet",
          "route53:CreateVPCAssociationAuthorization",
          "route53:DeactivateKeySigningKey",
          "route53:DeleteCidrCollection",
          "route53:DeleteDomain",
          "route53:DeleteHealthCheck",
          "route53:DeleteHostedZone",
          "route53:DeleteKeySigningKey",
          "route53:DeleteReusableDelegationSet",
          "route53:DeleteVPCAssociationAuthorization",
          "route53:DisassociateVPCFromHostedZone",
          "route53:GetAccountLimit",
          "route53:GetChange",
          "route53:GetCheckerIpRanges",
          "route53:GetDomainDetail",
          "route53:GetHealthCheck",
          "route53:GetHealthCheckCount",
          "route53:GetHealthCheckLastFailureReason",
          "route53:GetHealthCheckStatus",
          "route53:GetHostedZone",
          "route53:GetHostedZoneCount",
          "route53:GetHostedZoneLimit",
          "route53:GetReusableDelegationSet",
          "route53:GetReusableDelegationSetLimit",
          "route53:ListCidrBlocks",
          "route53:ListCidrCollections",
          "route53:ListCidrLocations",
          "route53:ListDomains",
          "route53:ListGeoLocations",
          "route53:ListHealthChecks",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:ListHostedZonesByVPC",
          "route53:ListOperations",
          "route53:ListResourceRecordSets",
          "route53:ListReusableDelegationSets",
          "route53:ListTagsForResource",
          "route53:ListTagsForResources",
          "route53:ListVPCAssociationAuthorizations",
          "route53:UpdateDomainNameservers",
          "route53:UpdateHealthCheck",
          "route53:UpdateHostedZoneComment",
          "route53:*",
          "route53domains:DeleteTagsForDomain",
          "route53domains:ListTagsForDomain",
          "route53domains:UpdateTagsForDomain",
          "route53domains:*"
        ]
        "Effect" : "Allow"
        "Resource" : "*"
      },
    ]
  })
}
