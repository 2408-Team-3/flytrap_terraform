variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "flytrap_lambda_function"
}

variable "vpc_id" {
  description = "Id of the VPC"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN for SQS queue"
  type        = string
}

variable "db_secret_arn" {
  description = "The ARN of the database secret in Secrets Manager"
  type        = string
}

variable "db_instance_arn" {
  description = "ARN for RDS db instance"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "VPC private subnet cidrs"
  type        = list(string)
}

variable "lambda_handler" {
  description = "The handler for the Lambda function"
  type        = string
  default     = "lambda.js"
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "nodejs14.x"
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
