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
  source               = "./modules/rds"
  vpc_id               = module.vpc.vpc_id
  db_subnet_ids        = module.vpc.private_subnet_ids
  private_subnet_cidrs = module.vpc.private_subnet_cidrs
}

module "sqs_provision" {
  source = "./modules/sqs_provision"
}

module "api_gateway" {
  source         = "./modules/api_gateway"
  region         = var.aws_region
  account_id     = data.aws_caller_identity.current.account_id
  sqs_queue_name = module.sqs_provision.sqs_queue_name
  sqs_queue_arn  = module.sqs_provision.sqs_queue_arn
}

module "sqs_configure" {
  source          = "./modules/sqs_configure"
  api_gateway_arn = module.api_gateway.api_gateway_execution_arn
  sqs_queue_arn   = module.sqs_provision.sqs_queue_arn
  sqs_queue_name  = module.sqs_provision.sqs_queue_name
  sqs_queue_id    = module.sqs_provision.sqs_queue_id
}

module "lambda" {
  source               = "./modules/lambda"
  vpc_id               = module.vpc.vpc_id
  db_secret_name       = module.rds.db_secret_name
  db_secret_arn        = module.rds.db_secret_arn
  db_endpoint          = module.rds.db_endpoint
  db_name              = module.rds.db_name
  db_instance_arn      = module.rds.db_arn
  private_subnet_cidrs = module.vpc.private_subnet_cidrs
  private_subnet_ids   = module.vpc.private_subnet_ids
  sqs_queue_arn        = module.sqs_provision.sqs_queue_arn
}

module "ec2" {
  source                   = "./modules/ec2"
  vpc_id                   = module.vpc.vpc_id
  public_subnet_id         = module.vpc.public_subnet_id[0]
  lambda_sg_id = module.lambda.lambda_sg_id
  flytrap_db_sg_id         = module.rds.flytrap_db_sg_id
  db_arn                   = module.rds.db_arn
  db_host                  = module.rds.flytrap_db_endpoint
  db_name                  = module.rds.db_name
  db_secret_arn            = module.rds.db_secret_arn
  db_secret_name           = module.rds.db_secret_name
  region                   = var.aws_region
  ami                      = var.ami
}