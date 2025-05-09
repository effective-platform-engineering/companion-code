{
  "aws_region": "us-east-1",
  "aws_account_id": "{{ op://<my-vault>aws-account-1/aws-account-id }}",
  "aws_assume_role": "Roles/IamProfilesRole",

  "is_state_account": false,
  "state_account_id": "{{ op://<my-vault>aws-account-2/aws-account-id }}",
  "all_nonprod_account_roles": [
      "arn:aws:iam::{{ op://<my-vault>aws-account-2/aws-account-id }}:role/Roles/*"
  ],
  "all_production_account_roles": [
      "arn:aws:iam::{{ op://<my-vault>aws-account-1/aws-account-id }}:role/Roles/*"
  ]
}
