### **Exercise 6.2: Create and run a configuration test against a built-in AWS role**

Use your personal, administrative-level AWS credentials and run the above iam\_role check against the AWS account you use for the exercises. Then, change the policy name to misspell it to test for a policy we know doesn’t exist and see how Rspec reports the failure. (Exercise code samples are available in the companion code.)

### **Solution**

Expected result.

$ rspec test.rb --format documentation

iam_role 'AdminUsersRole'  
  is expected to exist  
  is expected to have iam policy "AdministratorAccess"

Finished in 0.54632 seconds (files took 5.48 seconds to load)  
2 examples, 0 failures

$ rspec test_with_error.rb –-format documentation

iam_role 'AdminUsersRole'  
  is expected to exist  
  is expected to have iam policy "AdministratorAccess_oops" (FAILED - 1)

Failures:

  1) iam_role 'AdminUsersRole' is expected to have iam policy "AdministratorAccess_oops"  
  Failure/Error: it { should have_iam_policy('AdministratorAccess_oops') }  
  expected \`iam\_role 'AdminUsersRole'.has\_iam\_policy?("AdministratorAccess\_oops")\` to be truthy, got nil  
  \# ./test.rb:5:in \`block (2 levels) in \<top (required)\>'

Finished in 0.54097 seconds (files took 6.41 seconds to load)  
2 examples, 1 failure

Failed examples:

rspec ./test.rb:5 \# iam\_role 'AdminUsersRole' is expected to have iam policy "AdministratorAccess\_oops"