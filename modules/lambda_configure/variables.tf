variable "lambda_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "flytrap_lambda_function"
}

variable "sqs_queue_arn" {
  description = "ARN for SQS queue"
  type        = string
}

variable "db_instance_arn" {
  description = "ARN for RDS db instance"
  type        = string
}

variable "db_secret_arn" {
  description = "The ARN of the database secret in Secrets Manager"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "VPC private subnet cidrs"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC in which to create the RDS resources"
  type        = string
}