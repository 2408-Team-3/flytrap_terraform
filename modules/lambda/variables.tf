variable "vpc_id" {
  description = "Id of the VPC"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN for SQS queue"
  type        = string
}

variable "lambda_sg_id" {
  description = "The security group ID for Lambda access"
  type        = string
}

variable "lambda_handler" {
  description = "The handler for the Lambda function"
  type        = string
  default     = "lambda.js"
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "db_endpoint" {
  description = "The endpoint of the RDS database"
  type        = string
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "db_secret_name" {
  description = "The name of the database secret in Secrets Manager"
  type        = string
}

variable "private_subnet_ids" {
  description = "VPC private subnet ids"
  type        = list(string)
}

variable "ec2_url" {
  description = "EC2 url for accessing frontend and lambda webhook endpoint"
  type        = string
}

variable "lambda_iam_role_arn" {
  description = "ARN for the lambda IAM role"
  type        = string
}