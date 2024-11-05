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

module "vpc" {
  source = "./modules/vpc"
}

module "rds" {
  source        = "./modules/rds"
  vpc_id        = module.vpc.vpc_id
  db_subnet_ids = module.vpc.private_subnet_ids
}

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

module "sqs_configure" {
  source          = "./modules/sqs_configure"
  api_gateway_arn = module.api_gateway.api_gateway_execution_arn
  sqs_queue_arn   = module.sqs.sqs_queue_arn
  sqs_queue_name  = module.sqs.sqs_queue_name
  sqs_queue_id    = module.sqs.sqs_queue_id
}