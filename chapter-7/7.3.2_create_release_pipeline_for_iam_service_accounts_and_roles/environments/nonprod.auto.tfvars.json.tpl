{
  "aws_region": "us-east-1",
  "aws_account_id": "{{ op://empc-lab/aws-dps-2/aws-account-id }}",
  "aws_assume_role": "PlatformRoles/IamProfilesRole",

  "is_state_account": true,
  "state_account_id": "{{ op://empc-lab/aws-dps-2/aws-account-id }}",
  "all_nonprod_account_roles": [
      "arn:aws:iam::{{ op://empc-lab/aws-dps-2/aws-account-id }}:role/PlatformRoles/*"
  ],
  "all_production_account_roles": [
      "arn:aws:iam::{{ op://empc-lab/aws-dps-1/aws-account-id }}:role/PlatformRoles/*"
  ]
}
