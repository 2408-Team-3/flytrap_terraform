variable "lambda_handler" {
  description = "The handler for the Lambda function"
  type        = string
  default     = "processor.handler"
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "vpc_id" {
  description = "Flytrap VPC id"
  type        = string
}

variable "db_secret_name" {
  description = "The name of the database secret in Secrets Manager"
  type        = string
}

variable "db_host" {
  description = "The endpoint of the RDS database"
  type        = string
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "lambda_sg_id" {
  description = "The security group ID for Lambda access"
  type        = string
}

variable "lambda_iam_role_arn" {
  description = "ARN for the lambda IAM role"
  type        = string
}

variable "private_subnet_ids" {
  description = "VPC private subnet ids"
  type        = list(string)
}

variable "sqs_queue_arn" {
  description = "ARN for SQS queue"
  type        = string
}

variable "ec2_url" {
  description = "EC2 url for accessing frontend and lambda webhook endpoint"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}