terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">=1.0"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# add vpc here

module "sqs" {
  source = "./modules/sqs"
}

module "api_gateway" {
  source         = "./modules/api_gateway"
  region         = var.aws_region
  account_id     = data.aws_caller_identity.current.account_id
  sqs_queue_name = module.sqs.sqs_queue_name
  sqs_queue_arn  = module.sqs.sqs_queue_arn
}