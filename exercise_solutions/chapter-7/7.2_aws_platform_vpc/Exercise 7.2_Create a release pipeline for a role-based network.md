# Solutions to Exercise 7.2: Create a release pipeline for a role-based network
A new pipeline usually means a new Role defined in our pipeline_iam_profiles repo. Like in the previous pipeline exercise, add the test for the role.  
```bash
$ cat test/platform_vpc_role_spec.rb
require 'awspec'
describe iam_role('PlatformVPCRole') do
  it { should exist }
  it { should have_iam_policy('PlatformVPCRolePolicy') }
  it { should be_allowed_action('ec2:Accept*') }
  it { should be_allowed_action('ec2:AdvertiseByoipCidr') }
  it { should be_allowed_action('ec2:AllocateAddress') }
  . . .  #A
end
```
#A As with previous example, we will need to determine the actual permissions needed for our vpc pipeline. See complete example in code samples.  

Add the role definition along with the other roles already in the repo.  
```bash
$ cat platform_vpc_role.tf
module "PlatformVPCRole" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version     = "5.55.0"
  create_role = true
  role_name                         = "PlatformVPCRole"
  role_path                         = "/PlatformRoles/"
  role_requires_mfa                 = false
  custom_role_policy_arns           = [aws_iam_policy.PlatformVPCRolePolicy.arn]
  number_of_custom_role_policy_arns = 1
  trusted_role_arns = ["arn:aws:iam::${var.state_account_id}:root"]
}
# role permissions
resource "aws_iam_policy" "PlatformVPCRolePolicy" {
  name = "PlatformVPCRolePolicy"
  path = "/PlatformPolicies/"
  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : [
          "ec2:Accept*",
          "ec2:AdvertiseByoipCidr",
          "ec2:AllocateAddress",
          "ec2:AllocateIpamPoolCidr"
           . . .
        ]
        "Effect" : "Allow"
        "Resource" : "*"
      },
    ]
  })
}
```
Push these changes and deploy the new role to both accounts.  

Back to our vpc pipeline. Since in our example, we can assume we have fully reserved the cidr ranges of our networks within the enterprise allocation system, the depth of our tests could be limited to the following.  
```bash
# frozen_string_literal: true
require 'awspec'
require 'json'
tfvars = JSON.parse(File.read('./' + ENV['WORKSPACE'] + '.auto.tfvars.json')
describe vpc(tfvars['cluster_name'] + '-vpc') do
  it { should exist }
  it { should be_available }
  its(:cidr_block) { should eq tfvars['vpc_cidr'] }
end
```
If it is possible that someone outside the team managing these networks could make changes to the networks, then these tests should be expanded to include other parts of the configuration such as subnets, routing tables, and nat gateways.  

Like in our prior examples, having first created our tests, now is a good time to do the initial pipeline setup. Use the same starting lines from our prior terraform exercises.  

We can also reuse the set-environment command from our previous pipeline. Although, beginning with this VPC pipeline, we are now switching from account-specific configuration to cluster-specific configuration so rename the parameter passed to set-environment to cluster.  

Next, create the integration-test command.  
```yaml
commands:
. . .
integration-tests:
    description: run awspec aws configuration tests
    parameters:
      cluster:
        description: tf workspace name                       #A
        type: string
    steps:
      - run:
          name: run awspec aws configuration tests
          Environment:
            WORKSPACE: <<parameters.cluster>>                #B
          command: bash scripts/run_awspec_integration_tests.sh << parameters.cluster >>
```
#A This is our cluster name which we also use to identify the terraform workspace.  

#B Though we can pass the terraform workspace information as a regular parameter in the jobs provided by our terraform orb, notice how in the integration test we reference the cluster name via the WORKSPACE environment variable in order to fetch environment specific values.  

The bash script for our integration test will be very much like our other pipelines.  
```bash
#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh
export cluster_name=$1
export aws_account_id=$(jq -er .aws_account_id "$cluster_name".auto.tfvars.json)
export aws_assume_role=$(jq -er .aws_assume_role "$cluster_name".auto.tfvars.json)
export AWS_DEFAULT_REGION=$(jq -er .aws_region "$cluster_name".auto.tfvars.json)
awsAssumeRole "${aws_account_id}" "${aws_assume_role}"
rspec test/platform_vpc_spec.rb --format documentation
```
Add the integration test job.  
```yaml
jobs:
  recurring-integration-tests:
    description: |
      Recurring job (weekly) to run pipeline integration tests to detect aws configuration drift
    docker:
      - image: *executor-image
    environment:
      TF_WORKSPACE: << parameters.cluster >>
    parameters:
      cluster:
        description: cluster configuration
        type: string
    steps:
      - checkout
      - setup_remote_docker
      - set-environment:
          cluster: << parameters.cluster >>
      - integration-tests:
          cluster: << parameters.cluster >>
Add a workflow job for the recurring integration test, but without the scheduled triggers so we can validate our tests now.
weekly integration test:
    Jobs:
      - recurring-integration-tests:
          name: sbx-i01-aws-us-east-1 integration test
          context: *context
          cluster: sbx-i01-aws-us-east-1
      - recurring-integration-tests:                        #A
          name: prod-i01-aws-us-east-2 integration test
          context: *context
          cluster: prod-i01-aws-us-east-2
```
#A in the scheduled job we can run the jobs concurrently, though they are separate jobs with separate credentials needed.
The contents of the .env files for this pipeline are the same as for the platform-iam-profiles pipeline.  
```bash
op.sbx-i01-aws-us-east-1.env      #A
op.prod-i01-aws-us-east-2.env     #B
```
#A Same contents as op.nonprod.env from the profiles repo.  
#B Same contents as op.prod.env from the profiles repo.  

Push these changes and confirm that our test run correctly and fail. Once done, we can add in the workflow conditions to the recurring test.  
```yaml
weekly integration test:
    when:
      equal: [ scheduled_pipeline, << pipeline.trigger_source >> ]
    jobs:
    . . . 
```
Now we can add our VPC configuration. We really only need a single resource definition using the terraform aws provider vpc module.  
```bash
$ cat main.tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"
  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr
  azs  = var.vpc_azs
  # private, node subnet
  private_subnets       = var.vpc_private_subnets
  private_subnet_suffix = "private-subnet"
  private_subnet_tags   = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Tier"                                      = "node"              #A
    "karpenter.sh/discovery"                    = "${var.cluster_name}-vpc"
  }
  # public ingress subnet
  public_subnets       = var.vpc_public_subnets
  public_subnet_suffix = "public-subnet"
  public_subnet_tags   = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"                  #B
    "Tier"                                      = "public"             #A
  }
  # intra, non-outbound route subnet
  intra_subnets       = var.vpc_intra_subnets
  intra_subnet_suffix = "intra-subnet"
  intra_subnet_tags   = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Tier"                                      = "intra"               #A
  }
  # dedicated cluster database subnet
  database_subnets       = var.vpc_database_subnets
  database_subnet_suffix = "database-subnet"
  database_subnet_tags   = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Tier"                                      = "database"          #A
  }
  create_database_subnet_group = true                                 #C
  map_public_ip_on_launch = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true                                      #D
  single_nat_gateway      = true                                      #E
}
```
#A Apply a tag to identity the subnet so we can easily find it with terraform data resources in later pipelines.  

#B Identify the Load Balancer network with this tag. Our service mesh will use this tag to decide where to place classic or network load balancers.  

#C RDS and potentially other resources make use of a database subnet group. Where those kind of resources are provided by the Platform, network specific instances for the entire cluster will use the subnet group we define here.  

#D This natgw support provided by this terraform module is for the public subnet.  

#E We will only provision one, rather than one-per AZ.  

The tfvar files for our vpcs contain the detailed values outlined in the chart included in the exercise description. And of course include the new role we created for this pipeline.  
```json
$ cat environments/sbx-i01-aws-us-east-1.auto.tfvars.json.tpl
{
  "cluster_name": "sbx-i01-aws-us-east-1",
  "aws_account_id": "{{ op://my-vault/aws-account-2/aws-account-id }}",
  "aws_assume_role": "PlatformRoles/PlatformVPCRole",
  "aws_region": "us-east-1",
  "vpc_cidr": "10.80.0.0/16",
  "vpc_azs": [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ],
  "vpc_private_subnets": [
    "10.80.0.0/18",
    "10.80.64.0/18",
    "10.80.128.0/18"
  ],
  "vpc_intra_subnets": [
    "10.80.192.0/20",
    "10.80.208.0/20",
    "10.80.224.0/20"
  ],
  "vpc_database_subnets": [
    "10.80.240.0/23",
    "10.80.242.0/23",
    "10.80.244.0/23"
  ],
  "vpc_public_subnets": [
    "10.80.246.0/23",
    "10.80.248.0/23",
    "10.80.250.0/23"
  ]
}

$ cat environments/prod-i01-aws-us-east-2.auto.tfvars.json.tpl
{
  "cluster_name": "prod-i01-aws-us-east-2",
  "aws_account_id": "{{ op://my-vault/aws-account-1/aws-account-id }}",
  "aws_assume_role": "PlatformRoles/PlatformVPCRole",
  "aws_region": "us-east-2",
  "vpc_cidr": "10.90.0.0/16",
  "vpc_azs": [
    "Us-east-2a",
    "Us-east-2b",
    "Us-east-2c"
  ],
  "vpc_private_subnets": [
    "10.90.0.0/18",
    "10.90.64.0/18",
    "10.90.128.0/18"
  ],
  "vpc_intra_subnets": [
    "10.90.192.0/20",
    "10.90.208.0/20",
    "10.90.224.0/20"
  ],
  "vpc_database_subnets": [
    "10.90.240.0/23",
    "10.90.242.0/23",
    "10.90.244.0/23"
  ],
  "vpc_public_subnets": [
    "10.90.246.0/23",
    "10.90.248.0/23",
    "10.90.250.0/23"
  ]
}
```
In the variables.tf file there are some additional validations we can use for availability zones and cidr blocks.
```bash
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
```
Add similar validations for the other cidr variables. The versions.tf file will follow the same pattern we have established in our other terraforom pipelines.  

With the resources defined, let’s add the first stage (actions triggered by git-push) to our pipeline.  
```yaml
workflows:
  deploy sbx-i01-aws-us-east-1 vpc:
    when:
      not:
        equal: [ scheduled_pipeline, << pipeline.trigger_source >> ]
    jobs:
      - terraform/static-analysis:
          name: static code analysis
          context: *context
          executor-image: *executor-image
          workspace: sbx-i01-aws-us-east-1              #A
          tflint-scan: true
          tflint-provider: aws
          trivy-scan: true
          before-static-analysis:
            - op/env:
                env-file: op.sbx-i01-aws-us-east-1.env
          filters: *on-push-main
      - terraform/plan:
          name: sbx-i01-aws-us-east-1 change plan
          context: *context
          executor-image: *executor-image
          workspace: sbx-i01-aws-us-east-1
          before-plan:
            - set-environment:
                cluster: sbx-i01-aws-us-east-1
          filters: *on-push-main
      - approve sbx-i01-aws-us-east-1 changes:
          type: approval
          requires:
            - static code analysis
            - sbx-i01-aws-us-east-1 change plan
          filters: *on-push-main
      - terraform/apply:
          name: apply sbx-i01-aws-us-east-1 changes
          context: *context
          workspace: sbx-i01-aws-us-east-1
          before-apply:
            - set-environment:
                cluster: sbx-i01-aws-us-east-1
          after-apply:
            - integration-tests:
                cluster: sbx-i01-aws-us-east-1
          requires:
            - approve sbx-i01-aws-us-east-1 changes
          filters: *on-push-main
```
In this exercise, we can use the following .trivyignore directives for what amount to false-positives from capabilities in the vpc module we aren’t using.  
```bash
$ cat .trivyignore
AVD-AWS-0017
AVD-AWS-0057
AVD-AWS-0101
AVD-AWS-0102
AVD-AWS-0105
AVD-AWS-0178
```
Push these changes and confirm the tests validate that the sandbox vpc is successfully provisioned.  
Now we can add the release workflow.  
```yaml
  deploy prod-i01-aws-us-east-2 vpc:
    jobs:
      - terraform/plan:
          name: prod-i01-aws-us-east-2 change plan
          context: *context
          executor-image: *executor-image
          workspace: prod-i01-aws-us-east-2
          checkov-scan: true
          before-plan:
            - set-environment:
                cluster: prod-i01-aws-us-east-2
          filters: *on-tag-main
      - approve prod-i01-aws-us-east-2 changes:
          type: approval
          requires:
            - prod-i01-aws-us-east-2 change plan
          filters: *on-tag-main
      - terraform/apply:
          name: apply prod-i01-aws-us-east-2 changes
          context: *context
          workspace: prod-i01-aws-us-east-2
          before-apply:
            - set-environment:
                cluster: prod-i01-aws-us-east-2
          after-apply:
            - aws-integration-tests:
                cluster: prod-i01-aws-us-east-2
            - do/slack-bot:
                channel: platform-events
                message: Release aws-platform-vpc
                include-link: true
                include-tag: true
          requires:
            - approve prod-i01-aws-us-east-2 changes
          filters: *on-tag-main
      - do/gh-release:
          name: generate release notes
          context: *context
          notes-from-file: release.md
          include-commit-msg: true
          before-release:
            - op/env:
                env-file: op.prod-i01-aws-us-east-2.env
          requires:
            - apply prod-i01-aws-us-east-2 changes
          filters: *on-tag-main
```
Push these changes and tag the commit to release to prod.  
Finally, let’s add the scheduled integration test workflow, and push the changes.  
```yaml
  schedule weekly integration test:
    jobs:
      - do/schedule-pipeline:
          name: weekly integration test
          context: *context
          scheduled-pipeline-name: weekly-integration-test
          scheduled-pipeline-description: |
            Weekly, automated run of platform vpc integration tests
          hours-of-day: "[1]"
          days-of-week: "[\"SUN\"]"
          Before-schedule:
            - op/env:
                env-file: op.prod-i01-aws-us-east-2.env
          filters: *on-tag-main
```
