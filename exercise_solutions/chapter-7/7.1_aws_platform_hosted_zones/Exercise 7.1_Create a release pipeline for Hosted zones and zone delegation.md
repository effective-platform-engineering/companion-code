# Solutions to Exercise 7.1: Create a release pipeline for hosted zone and zone delegation

First we need to define a new role in the platform-iam-profiles repository. Start by adding the associated test.
```bash
$ cat test/platform_hosted_zones_spec.rb
require 'awspec'
describe iam_role('PlatformHostedZonesRole') do
  it { should exist }
  it { should have_iam_policy('PlatformHostedZonesRolePolicy') }  
  it { should be_allowed_action('route53:AcceptDomainTransferFromAnotherAwsAccount') }
  it { should be_allowed_action('route53:AssociateVPCWithHostedZone') }
  it { should be_allowed_action('route53:CancelDomainTransferToAnotherAwsAccount') }
  . . .  #A
end
```
#A Review the AWS list of Route53 and Route53Domain permission to decide which permission will be necessary to manage host zones and delegations. See a complete list of permission in the companion code example.  

Then, add the actual role definition:
```bash
$ cat platform_hosted_zones_role.tf
# PlatformHostedZonesRole
#
# Used by: platform-hosted-zones pipeline
module "PlatformHostedZonesRole" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version     = "5.55.0"
  create_role = true
  role_name                         = "PlatformHostedZonesRole"
  role_path                         = "/PlatformRoles/"
  role_requires_mfa                 = false
  custom_role_policy_arns           = [aws_iam_policy.PlatformHostedZonesRolePolicy.arn]
  number_of_custom_role_policy_arns = 1
  trusted_role_arns = ["arn:aws:iam::${var.state_account_id}:root"] #A
}
# role permissions
resource "aws_iam_policy" "PlatformHostedZonesRolePolicy" {
  name = "PlatformHostedZonesRolePolicy"
  path = "/PlatformPolicies/"
  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : [
          "route53:AcceptDomainTransferFromAnotherAwsAccount",
          "route53:AssociateVPCWithHostedZone",
          "route53:CancelDomainTransferToAnotherAwsAccount",
          . . .    #B
        ]
        "Effect" : "Allow"
        "Resource" : "*"
      },
    ]
  })
}
```
#A recall, in the four-account strategy, service account only exist in the state account and trust to assume is from that account. In our examples we will use only two account, and in this case what we are calling the nonprod account acts like the state account (use the nonprod account id here).  

#B These are the matching permissions from the test.  

With the role added, push these changes and release to both accounts via the platform-iam-profile pipeline.  

Now, back to our platform-hosted-zones repo, define the tests for the zones to be created in the same account as the primary domain (account-1).  
```bash
$ cat test/prod_account_spec.rb
require 'awspec'
describe route53_hosted_zone('epetech.io.') do
  it { should exist }
end
describe route53_hosted_zone('prod-i01-aws-us-east-2.epetech.io.') do
  it { should exist }
end
describe route53_hosted_zone('dev.epetech.io.') do
  it { should exist }
end
describe route53_hosted_zone('qa.epetech.io.') do
  it { should exist }
end
describe route53_hosted_zone('api.epetech.io.') do
  it { should exist }
end
Next, the the zones delegated to our sandbox account.
$ cat test/nonprod_account_spec.rb
require 'awspec'
describe route53_hosted_zone('sbx-i01-aws-us-east-1.epetech.io.') do
  it { should exist }
end
describe route53_hosted_zone('preview.epetech.io.') do
  it { should exist }
end
```

You will save pipeline development time later if you start enabling the pipeline as soon as you have written the automated tests of your configuration.  

Add our initial pipeline configuration, defining the orbs we will use and the triggers for our workflows, to .circleci.config.yml.  
```yaml
---
version: 2.1
orbs:
  terraform: twdps/terraform@3.1.1
  op: twdps/onepassword@3.0.0
  do: twdps/pipeline-events@5.1.0
globals:
  - &context <my-team>
  - &executor-image twdps/circleci-infra-aws:alpine-2025.04
on-push-main: &on-push-main
  branches:
    only: /main/
  tags:
    ignore: /.*/
on-tag-main: &on-tag-main
  branches:
    ignore: /.*/
  tags:
    only: /.*/
```
Since we will apply all changes at once, we will not need different contexts for secrets so ew can have a single op.env file with the following credentials:  
```bash
export TFE_TOKEN={{ op://my-vault/svc-terraform-cloud/team-api-token }}
export AWS_ACCESS_KEY_ID={{ op://my-vault/aws-account-2/ProdServiceAccount-aws-access-key-id }}
export AWS_SECRET_ACCESS_KEY={{ op://my-vault/aws-account-2/ProdServiceAccount-aws-secret-access-key }}
export SLACK_BOT_TOKEN=op://my-vault/svc-slack/post-bot-token
export GH_TOKEN={{ op://my-vault/svc-github/access-token }}
```
Then add our typical set-environment command that injects this values, sets up our terraform cloud access, and so on.  
```yaml
commands:
  set-environment:
    parameters:
      account:
        description: account description
        type: string
    steps:
      - op/env:
          env-file: op.env
      - op/tpl:
          tpl-path: environments
          tpl-file: << parameters.account >>.auto.tfvars.json
      - terraform/terraformrc
      - do/bash-functions
```
We will actually have only one tfvars file since we apply these changes in a single pass. But we do need the values and we will still inject account id information. Let’s call our environment _multiaccount_ to indicate more than one account is involved.  
```bash
$ cat environments/multiaccount.auto.tfvars.json.tpl
{
  "nonprod_account_id": "{{ op://my-vault/aws-account-2/aws-account-id }}",
  "prod_account_id": "{{ op://my-vault/aws-account-1/aws-account-id }}",
  "assume_role": "PlatformRoles/PlatformHostedZonesRole"             #A
}
```
#A We refer to the pipeline role we created as our first action above.  

The first thing our pipeline will do is run the integration tests, so add a command for that. Since we are applying configuration to two accounts at the same time, we can run both of the account-level tests. However, awspec tests will need to assume a role one account at a time so our test script will need to be called at least twice since we are using two accounts in our examples.  
```yaml
Commands:
. . .
  integration-tests:
    parameters:
      account:
        description: account description
        type: string
    steps:
      - run:
          name: integration test nonprod account
          command: bash scripts/hosted_zone_test.sh << parameters.account >> nonprod
      - run:
          name: integration test prod account
          command: bash scripts/hosted_zone_test.sh << parameters.account >> prod
```
The hosted_zone_test.sh script is just like our other awspec test procedures. We assume the appropriate role and then run the test using the desired spec file.  
```bash
$ cat scripts/hosted_zone_test.sh
#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh
export environment=$1
export account=$2
export aws_account_id=$(jq -er ."${account}"_account_id "$environment".auto.tfvars.json)                              #A
export aws_assume_role=$(jq -er .assume_role "$environment".auto.tfvars.json)
export AWS_DEFAULT_REGION=us-east-1
awsAssumeRole "${aws_account_id}" "${aws_assume_role}"         #B
rspec "test/${account}_account_spec.rb"
```
#A Pull the account id and role information from the tfvars file.  

#B Use the bash function added by the pipeline-events orb.  

We know that our completed pipeline will have a scheduled job to runs these tests routinely. But as part of setting up our pipeline and debugging the flow of the test, let’s first add that recurring job as the only job, and leave out the filters or conditions that would normally be used to adjust when the job runs. The will result in the first iteration of our pipeline simply performing the awspec tests.  
```yaml
jobs:
  recurring-integration-tests:
    description: |
      Recurring job (weekly) to run pipeline integration tests to detect aws configuration drift
    docker:
      - image: *executor-image
    parameters:
      account:
        description: account description
        type: string
    steps:
      - checkout
      - setup_remote_docker
      - set-environment:
          account: << parameters.account >>
      - integration-tests:
          account: << parameters.account >>
Workflows:
  weekly integration test:
    Jobs:
      - recurring-integration-tests:
          name: AWS hosted zones integration test
          context: *context
          account: multiaccount
```
Push these changes, and start the project building in the CircleCI. Confirm that the integration tests successfully test for the presence of the desired zones, though of course the tests are failing at this point.  
Now let’s add our zone delegation files. In addition to the domain data resource file and preview.epetech.io delegation examples from the chapter section, we need to add zones for each of the zones defined in table 7.1. The preview subdomain is a cross-account delegation, here is an example of delegation with the same account.  
```bash
$ cat zone_dev_epetech_io.tf
# define a provider in the account where this subdomain will be managed
provider "aws" {
  alias  = "subdomain_dev_epetech_io"
  region = "us-east-2"
  assume_role {
    role_arn     = "arn:aws:iam::${var.prod_account_id}:role/${var.assume_role}"    #A
    session_name = "platform-hosted-zones"                       #B
  }
}
# create a route53 hosted zone for the subdomain
module "subdomain_dev_epetech_io" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "3.1.0"
  create  = true
  providers = {
    aws = aws.subdomain_dev_epetech_io                         #C
  }
  zones = {
    "dev.${local.domain_epetech_io}" = {                        #D
      tags = {
        cluster = "prod-i01-aws-us-east-2"                         #E
      }
    }
  }
}
# Create a zone delegation in the top level domain for this subdomain
module "subdomain_zone_delegation_dev_epetech_io" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "3.1.0"
  create  = true
  providers = {
    aws = aws.domain_epetech_io                                    #F
  }
  private_zone = false                                                #G
  zone_name = local.domain_epetech_io
  records = [
    {
      name            = "dev"
      type            = "NS"
      ttl             = 172800
      zone_id         = data.aws_route53_zone.zone_id_epetech_io.id
      allow_overwrite = true
      records         = module.subdomain_dev_epetech_io.route53_zone_name_servers["dev.${local.domain_epetech_io}"]
    }
  ]
  depends_on = [module.subdomain_dev_epetech_io]
}
```
#A The provider definition is where we reference the role we just deployed via the profiles pipeline to assume with permissions to make these changes.  

#B We can also add a session name to the sts assume role action for audit log purposes.  

#C The provider referenced here is the provider where we want to create the hosted zone.  

#D This zone is a subdomain of the primary domain.  

#E We can add tags to the DNS records.  

#F Now we use the provider for the account where the primary domain is registered. In the case of the dev. subdomain this is the same account. In the preview. subomain example it was a different account.  

#G In these examples we are using only public domain records.  

In addition to the preview and dev subdomains, create files for the following delegations:  
zone_sbx_i01_aws_us_east_1_epetech_io.tf  
zone_qa_epetech_io.tf  
zone_api_epetech_io.tf  
zone_prod_i01_aws_us_east_2_epetech_io.tf   

Follow the same pattern and modify for each needed zone and delegation.  

With the resource files created, let’s begin iterating on the pipeline. Add the scheduling condition to the weekly test job so it will not run with every change:  
```yaml
  weekly integration test:
    when:
      equal: [ scheduled_pipeline, << pipeline.trigger_source >> ]
    jobs:
     . . .
```
Now, add a workflow for the git-push stage that performs the terraform static analysis and plan jobs.  
```yaml
workflows:
  hosted-zones change plan: 
    Jobs: 
      - terraform/static-analysis:
          name: static code analysis
          context: *context
          executor-image: *executor-image
          workspace: state                               #A
          tflint-scan: true
          tflint-provider: aws
          trivy-scan: true
          before-static-analysis:
            - op/env:                                    #B
                env-file: op.env
          filters: *on-push-main


      - terraform/plan:
          name: hosted-zones change plan
          context: *context
          executor-image: *executor-image
          workspace: state
          before-plan:
            - set-environment:       
                account: multiaccount                   #C
          filters: *on-push-main
```
#A We will only have a single state file for this pipeline. It wouldn’t make sense to name it for any one account, so let’s just call it state.  

#B The static-analysis step only needs our op.env, not the rest of the set-environment command.  

#C We still pass an account parameter but we will only pass one, which we named multiaccount.  

Push these pipeline changes and debug any issues that the static-analysis reveals and review the resulting change plan.  
If everything checks out, add the release stage to our pipeline.  
```yaml
  hosted-zones release:
    jobs:
      - terraform/apply:
          name: hosted-zones release
          context: *context
          workspace: state
          before-apply:
            - set-environment:
                account: multiaccount
          after-apply:
            - integration-tests:
                account: multiaccount
            - do/slack-bot:
                channel: engineering platform events
                message: Release platform-hosted-zones
                include-link: true
                include-tag: true
          filters: *on-tag-main
      - do/gh-release:
          name: generate release notes
          context: *context
          notes-from-file: release.md
          include-commit-msg: true
          before-release:
            - op/env
          requires:
            - hosted-zones release
          filters: *on-tag-main
```
Push these changes, and then tag the successful commit and release the changes in our accounts.  

Before we leave this pipeline, lets complete the scheduling of the recurring tests but add the associated conditions and jobs.  
```yaml
workflows:
  hosted-zones change plan:
    when:
      not:
        equal: [ scheduled_pipeline, << pipeline.trigger_source >> ]
    jobs:
      . . .

  schedule weekly rotation and integration test:
    Jobs:
      - do/schedule-pipeline:
          name: weekly integration test
          context: *context
          scheduled-pipeline-name: weekly-integration-test
          scheduled-pipeline-description: |
            Weekly, automated run of aws hosted zone integration tests.
          hours-of-day: "[1]"
          days-of-week: "[\"SUN\"]"
          Before-schedule:
            - op/env:
                env-file: op.env
          filters: *on-tag-main
```