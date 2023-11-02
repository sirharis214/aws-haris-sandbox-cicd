terraform {
  # Terraform core should be pinned to a minor version
  required_version = "= 1.5.6"
  required_providers {
    # Providers should be pinned to a major version
    # The provider source should always be specified
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.14.0"
    }
  }
  backend "s3" {
    region = "us-east-1"
    bucket = "aws-haris-sandbox20230828153749772900000001"
    key    = "terraform/aws-haris-sandbox-cicd/terraform.tfstate"
  }
}

provider "aws" {
  # Update with your desired region
  region = "us-east-1"
  assume_role {
    role_arn     = var.ROLE_ARN
    external_id  = var.EXTERNAL_ID
    session_name = "aws-haris-sandbox-cicd"     # repo-branch ; module-workspace
  }
}
