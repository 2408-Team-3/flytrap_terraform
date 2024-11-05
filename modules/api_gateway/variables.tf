variable "region" {
  description = "The AWS region"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "sqs_queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  type        = string
}

variable "api_name" {
  description = "The name of the API Gateway REST API"
  type        = string
  default     = "flytrap-api"
}