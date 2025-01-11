### **6.7 Exercise: Create the CI and development test pipeline for IAM service accounts and roles**

Now we are ready to complete the rest of the first stage of our pipeline according to the workflow diagram above and test it against our nonprod account. Complete the above starting setup by adding the workflows and commands needed into sections “commands” and “workflows”. Wait until the next exercise to work on the credential rotation step. Don’t forget to uncomment the lines from versions.tf that cause Terraform to attempt to assume the needed IAM Role.

When using the static-code-analysis, plan, or apply jobs from the Terraform orb, remember that you can pass commands as a parameter and they will be run at the place you specify in the job. If we discover the need to set up some credentials or inject values into a tfvars template, we can easily do that without changing the orb directly.

When you are ready to start triggering the pipeline, go to our CircleCI organization, find the aws-iam-profiles repo among the projects, and start building. When you click set up project you will be asked whether you want to add a config.yml or use one already in the repo. Choose the option to use the pipeline you have created on the main branch. This step of setting up a project in CircleCI only happens when first connecting CIrcleCI to a repository

You can see in this pipeline the impact of using versioned pipeline code steps or jobs. In this case, the terraform orb we used provides most of the functionality we need for a typical terraform pipeline, including hooks that let us provide custom commands at various points in the workflow. The orb provides pre-configured steps for calling the static analysis tools we have decided to use. In the future, should the technical details for interacting with the tool change or even a change in the tool itself, we can release a new version of the orb for users to adopt and afford a window of time for users to adopt before deprecating the earlier pattern.

### **Solutions to Exercise 6.7: Create the CI and development test pipeline for IAM service accounts and roles**

Start with the first step from our workflow diagram.

workflows:  
  deploy service accounts and roles to state account:  \#A  
    jobs:

      \- terraform/static-analysis:                     \#B  
          name: static code analysis  
          context: \*context                            \#C  
          executor-image: \*executor-image              \#D  
          workspace: nonprod                           \#E  
          tflint-scan: true                            \#F  
          tflint-provider: aws                         \#G  
          trivy-scan: true                             \#H  
          filters: \*on-push-main                       \#I

**\#A** The first work flow will be all the steps that happen when we push a code change. Since that will involve deploying service accounts and roles to the first account, we will name the workflow with a description that hopefully makes that clear.

**\#B** The first step in our workflow is to perform a static analysis of our terraform code. We are using the twdps/terraform@3.0.1 orb that is publicly available in the CircleCI orb registry. That orb contains a job called static-analysis

**\#C** Add the team context we set up in the prerequisite section so that our pipeline will be able to successfully use the 1password orb to fetch secrets from our op vault. Since we will need to provide the context in many different jobs in this workflow, we defined the context setting in a global anchor that we can refer to wherever needed and yet still change it by making a change in only one location.

**\#D** The terraform orb uses a preconfigured opensource executor that comes with all the needed versions of tools. Though the orb will use the latest stable release by default, we will always want to pin to a specific executor so that the tool versions will align to our code and environments.

**\#E** This configuration is an account-level config. SInce we are only using two accounts in the exercising, we can refer to the test environment as simply nonprod and then prod for the prod account. We will name our workspaces to match.

**\#F** The static-analysis job in the terraform orb will perform tflint scan by setting the parameter to true.

**\#G** And since we are use AWS, we tell the tflint command in the orb to use the AWS provider plugin for tflint.

**\#H** We also want to perform a Trivy scan and can accept the default scan parameters.

**\#I** Use our git-push anchor to define the filter that will limit this step to running only when a change is pushed to main.

With this step defined, we can push these changes and then set up the pipeline in CircleCI.

(PICTURE OF SUCCESSFUL RUN)

Now add the plan step:

      \- terraform/plan:  
          name: nonprod change plan  
          context: \*context  
          executor-image: \*executor-image  
          workspace: nonprod  
          before-plan:                        \#J  
            \- set-environment:  
                account: nonprod  
          filters: \*on-push-main              \#K

**\#K** We do not need to make the plan step dependent on a successful completion of the static-analsys step, the jobs can run in parallel.

**\#J** Now that we are running the Terraform plan we will need some credentials available. Specifically, we will need the NonprodServiceAccount AWS credentials which the pipeline will use in assuming the platform-iam-profiles Role. And we will need the credential for our Terraform cloud account where we are storing the terraform state files. In addition, we will need to tfvars values for the nonprod account.

Getting these credentials setup in the correct manner will require a few steps. Create a local command in the command section of our pipeline.

commands:  
  set-environment:                                    \#L  
    description: generate environment credentials  
                 and configuration from templates  
    parameters:  
      account:                                        \#M  
        description: account to be configured  
        type: string  
    steps:  
      \- op/env:                                       \#N  
          env-file: op.\<\< parameters.account \>\>.env  
      \- op/tpl:                                       \#O  
          tpl-path: environments  
          tpl-file: \<\< parameters.account \>\>.auto.tfvars.json  
      \- terraform/terraformrc                         \#P

**\#L** Use a description name for our setup command.

**\#M** We will use this command both in this CI (git push) job as well as a tagged release. Define a parameter that we can pass to the set-environment command to support this usage.

**\#N** First let’s fetch the values we will need from our 1password vault using an op.env file.

\# op.nonprod.env  
export TFE\_TOKEN={{ op://my-vault/svc-terraform-cloud/team-api-token }}

export AWS\_ACCESS\_KEY\_ID={{ op://my-vault/aws-account-2/NonprodServiceAccount-aws-access-key-id }}  
export AWS\_SECRET\_ACCESS\_KEY={{ op://my-vault/aws-account-2/NonprodServiceAccount-aws-secret-access-key }}

Specifically, we will need to initialize the terraform backend and assume an IAM role so we will need the team terraform cloud api-token and the NonprodServiceAccount credentials that we created and saved earlier. We will have two op.env files. One for each account we will configure. We pass in the account name and use this to build the filename where the values are defined. The step uses a command from the 1password orb. Note the 1password value reference is made up of the vault, the item, and the field from the item. Use the details from the location where you stored these credentials. Adopt a naming convention that makes it easy to reference secrets from the vault.

**\#O** We also need to take our tfvars template from the environments folder and inject the account\_id into the file and then write a copy to the root folder that will automatically be picked up by terraform as our tfvars file for this plan. There is also a command in the 1password that performs this step. The command supports a number of parameters to support overriding the location and naming conventions of the file. This example assumes the templates are in the environment folder and that they are named to match the provided template name plus .tpl. Using json format for tfvars files makes supporting templates and other kinds of runtime analysis much easier. 

**\#P** Lastly, we want to use the TFE\_TOKEN from our environment values that were loaded in the first step to write a \~/.terraformrc file in the correct format for accessing our terraform cloud state store. The terraform orb includes a command that will do this.

Push these changes and check the result plan output in the step logs in circleci.

Once the analysis and plan steps are running, we can add an approval step that will pause the pipeline while we evaluate the plan output. This approval step should be contingent on the successful completion of the prior steps.

      \- approve nonprod changes:  
          type: approval  
          requires:                               \#Q  
            \- static code analysis  
            \- nonprod change plan  
          filters: \*on-push-main

**\#Q** This approval step should be contingent on the successful completion of the prior steps. Use the requires: key to set this requirement.

Now add the apply step.

      \- terraform/apply:  
          name: apply nonprod changes  
          context: \*context  
          workspace: nonprod  
          Before-apply:  
            \- set-environment:  
                account: nonprod  
          Requires:                                 \#R  
            \- approve nonprod changes  
          filters: \*on-push-main

**\#R** At this point, the apply step parameters we supply the apply job from the terraform orb is nearly identical to our plan step. This step must be contingent on the approval step.

At this point we can push these changes and our pipeline will perform the first two steps, then pause waiting for us to review the plan. If we think the plan looks good, we can approve the next step and the changes will be applied to the account.

The next step in the workflow diagram is to perform the awspec configuration tests we created earlier to confirm the service accounts and roles are configured as we expect.

We could create a complete new job, but our terraform orb supports adding custom steps after the apply step similar to how we could add custom steps prior to performing the apply step. Since AwSpec is an rspec extension and rspec tests are run using a standard pattern, we should consider creating either an awspec orb, or perhaps just adding an awspec command to our terraform orb. We probably should to that before using the terraform orb internally with our platform customers should we ever provide them with terraform starterkits. But we can also create a local command. In either case, supplying this command to the apply job as an after-apply parameter is cleaner than creating a whole new job.

          after-apply:  
            \- aws-integration-tests:                \#S  
                account: nonprod

**\#S** What do we need to do in the integration test?

  aws-integration-tests:  
    parameters:  
      account:  
        description: for example solution this is either nonprod or prod  
        type: string  
      steps:  
        \- run:  
            name: Awspec tests of pipeline managed AWS resources  
            command: bash scripts/run\_awspec\_integration\_tests.sh \<\< parameters.account \>\>

In keeping with our dump-pipelines strategy, the actual logic of the test is better kept in a local bash script. We will pass our account-name environment value to the script. Here is a possible solution for an AwSpec testing script.

\# scripts/run\_aws\_integration\_tests.sh  
\#\!/usr/bin/env bash

source bash-functions.sh     
set \-eo pipefail

export environment=$1  
export aws\_account\_id=$(jq \-er .aws\_account\_id "$environment".auto.tfvars.json)                            \#T

export aws\_assume\_role=$(jq \-er .aws\_assume\_role "$environment".auto.tfvars.json)

export AWS\_DEFAULT\_REGION=$(jq \-er .aws\_region "$environment".auto.tfvars.json)

awsAssumeRole "${aws\_account\_id}" "${aws\_assume\_role}"      \#U

\# test roles  
rspec test/\*.rb \--format documentation                      \#V

\# if this is the state account then test the profiles  
if \[\[ ${environment} \== "nonprod" \]\]; then                   \#W  
  rspec test/state/platform\_iam\_service\_accounts\_spec.rb \--format  
Documentation  
Fi

**\#T** These export command pull the required setting from our tfvars file.

**\#U** When we did the terraform-apply step, terraform used the assume\_role information in the provider resource to assume the correct role. But we are not using terraform in this step and out ENV just has the service account credentials. Before we can run the tests, we must assume the correct role. This bash function performs that step. But where is this function and how can we call it locally?

Add the following line to the set-environment command:

       \- do/bash-functions

This is a command that is in the pipeline-events orb we included in our pipeline. When you call this command, the file bash-functions.sh is written to the PWD. Take a look at the source code for the orb to see what functions it provides and what each does. 

**\#V** Now we can run all the awspec tests in the test folder. At this point there is only the test of the platform-iam-profiles role. But as we add more roles for future pipelines there will be more test files.

**\#W** And finally this script checks to see if we are in the workspace that includes our AWS services accounts. If so then it runs those tests, which we placed in the state folder.

Push these changes and debug any issues. At this point we have everything in our first stage pipeline workflow running except for the IAM service account credentials rotation.