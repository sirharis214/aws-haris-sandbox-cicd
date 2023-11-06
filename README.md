# aws-haris-sandbox-cicd
CI/CD. Creating infrastructure in AWS account aws-haris-sandbox via terraform and AWS Codebuild

![overview](/docs/images/aws-haris-sandbox-cicd.drawio.png)

# Disclaimer

:warning: This CI/CD is not ment to be a practical and ideal CI/CD setup. I have purposely broken this into 2 seperate GitHub repo's and 2 seperate AWS CodeBuild Projects, with one of them requiring to be triggered manually. The purpose of this CI/CD was to learn and document how AWS CodeBuild is used to pull code from GitHub and run terraform plan/apply on that code in AWS to create the infrastructure.

The ideal CI/CD would be wrap these 2 CodeBuild projects within a AWS Codepipline and integrate notifications and manual terraform-plan validation which would automatically trigger the CodeBuild apply project. 

The ideal setup would also be to not have this repo `aws-haris-sandbox-cicd`, rather, have the webhook attached to the repo where the CI/CD infrastructure is being created, [aws-haris-sandbox](https://github.com/sirharis214/aws-haris-sandbox). 

# Introduction

This repository will house all the module calls to create infrastructure in our AWS account. 

We will create various GitHub repositories which will be terraform modules that create AWS resources. We will then call those modules in this repo to create an instance of those resources in our AWS account.

## Example

We have a module [secure-s3-bucket](https://github.com/sirharis214/secure-s3-bucket) which we can call to create a S3 bucket. Checkout the documentation in that repo for detail's on the required and optional variables.

```hcl
module "example_bucket" {
  source       = "git::https://github.com/sirharis214/secure-s3-bucket?ref=v0.0.1"
  bucket_name  = "haris-example-bucket"
  project_tags = local.tags
}

```

# CI/CD Infrastructure 

The repository [aws-haris-sandbox](https://github.com/sirharis214/aws-haris-sandbox) created all the CI/CD infrastructure including the AWS CodeBuild projects and CodeBuild plan's webhook to this repository. This also means that terraform `aws-haris-sandbox` is not ran through CI/CD, rather, the terraform is executed locally. The statefiles are stored remotely in the dedicated S3 Bucket where all terraform statefiles are located.

* Terraform statefile S3 Bucket 
    - `aws-haris-sandbox20230828153749772900000001/terraform/<REPO_NAME>/terraform.tfstate`

## CI/CD CodeBuild Projects

* CodeBuild Projects
    - `aws-haris-sandbox-cicd-plan`
        - gets terraform code from GitHub
        - runs `terraform plan` on code
        - stores plan output file to artifacts bucket
    - `aws-haris-sandbox-cicd-apply`
        - gets plan output file from artifacts bucket
        - runs `terraform apply -auto-approve` on it

There are 2 CodeBuild Projects, one for terraform plan and the other for terraform apply. 

The **plan** CodeBuild project has a webhook attached to this GitHub repo. When a Pull Request **merges** the `feature` branch to `dev` branch, the CodeBuild plan project gets triggered. It clones the dev branch of this repo and runs `terraform plan` on it, saving the plan output to a file which will be stored in the artifacts S3 bucket, `plan.out`. 

The **apply** CodeBuild project needs to be executed manually via AWS Console. It grabs all the files stored in the artifacts bucket for this repo, which includes the plan output file, `plan.out`. Once the environment is setup, CodeBuild then runs terraform apply on the output file and creates the infrastructure. 

The [IAM role](./main.tf#L22) assumed by this repo has permissions to create any resource in AWS so there shouldn't be any restrictions on which sort of resources we can create. Ofcourse this can simply be changed by updating the [permissions](https://github.com/sirharis214/aws-haris-sandbox/blob/main/modules/cicd/iam.tf#L48) of the role.

