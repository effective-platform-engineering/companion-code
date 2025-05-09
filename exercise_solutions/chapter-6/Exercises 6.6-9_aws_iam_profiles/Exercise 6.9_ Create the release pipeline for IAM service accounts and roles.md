### **6.9 Exercise: Create the release pipeline for IAM service accounts and roles**

We need a trigger that will watch for new tags.

on-tag-main: \&on-tag-main  
  Branches:  
    ignore: /.\*/  
  Tags:  
    only: /.\*/

Now add a workflow for the release job in the pipeline. We only need to deploy to a single account since we only use two accounts instead of four in our simplified example. This means we only need to add the first column from diagram 6.17.

### **Solutions to Exercise 6.9: Create the release pipeline for IAM service accounts and roles**

workflows:

...

  deploy roles to prod:  
    jobs:  
      \- terraform/plan:                                \#A  
          name: prod change plan  
          context: \*context  
          executor-image: \*executor-image  
          workspace: prod  
          before-plan:  
            \- set-environment:  
                account: prod                          \#B  
          filters: \*on-tag-main

      \- approve prod changes:  
          type: approval  
          requires:  
            \- prod change plan  
          filters: \*on-tag-main

      \- terraform/apply:  
          name: apply prod changes  
          context: \*context  
          workspace: prod  
          before-apply:  
            \- set-environment:  
                account: prod  
          After-apply:                              \#C  
            \- aws-integration-tests:  
                account: prod  
          requires:  
            \- approve prod changes  
          filters: \*on-tag-main

**\#A** We are using the terraform orb in the same way as we did in the first stage, changing only the workspace name to match the correct tfvars and backend state name.

**\#B** We are making this change in a different account so we need an account specific op.env file. The TFE\_TOKEN is the same, but since this is our Production account, we use the ProdServiceAccount credentials.

\# op.prod.env  
export TFE\_TOKEN={{ op://my-vault/svc-terraform-cloud/team-api-token }}  
export AWS\_ACCESS\_KEY\_ID={{ op://my-vault/aws-account-2/ProdServiceAccount-aws-access-key-id }}  
export AWS\_SECRET\_ACCESS\_KEY={{ op://my-vault/aws-account-2/ProdServiceAccount-aws-secret-access-key }}

**\#C** Notice, we do not want to rotate the service account credentials in rhe release pipeline. The service accounts only exist in one account.

See the example complete repository contents at: (link to accompanying code)