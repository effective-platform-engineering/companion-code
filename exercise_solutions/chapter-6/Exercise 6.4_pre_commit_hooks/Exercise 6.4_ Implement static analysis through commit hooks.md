### **Exercise 6.4: Implement static analysis through commit hooks**

Create a new git repository locally and add the uncorrected main.tf file from Exercise 6.3.

Using the Python package pre-commit, apply pre-commit hooks that perform each of the above four common scans for terraform pipelines.

### **Solution**

Solution.

Repos:  
  \- repo: https://github.com/antonbabenko/pre-commit-terraform     \#A  
    rev: v1.89.1  
    Hooks:  
      \- id: terraform\_validate  
      \- id: terraform\_fmt  
      \- id: terraform\_tflint  
      \- id: terraform\_trivy  
  \- repo: local                                                    \#B  
    Hooks:  
      \- id: git-secrets  
        name: git-secrets  
        entry: git-secrets  
        language: system  
        args: \["--scan"\]  
  \- repo: [https://github.com/pre-commit/pre-commit-hooks](https://github.com/pre-commit/pre-commit-hooks)  
     rev: v4.5.  
     Hooks:  
       \- id: check-symlinks                                        \#C  
       \- id: check-merge-conflict  
       \- id: check-added-large-files  
       \- id: forbid-new-submodules  
       \- id: check-executables-have-shebangs                       \#D  
       \- id: check-json  
       \- id: check-yaml  
         args: \[--allow-multiple-documents\]  
       \- id: trailing-whitespace  
         args: \[--markdown-linebreak-ext=md\]

**\#A** This pre-commit plug has built-in commands for each Terraform tool in our previous examples.

**\#B** Example of the commit-hook referencing a locally installed tool.

**\#C** These four lines check for common git conventions

**\#D** The remainder of the commands in this general list perform basic linting against the common file types frequently found alongside Terraform files in an infrastructure pipeline: YAML, JSON, bash scripts, and markdown.