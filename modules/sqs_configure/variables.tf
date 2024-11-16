variable "api_gateway_arn" {
  description = "The ARN of the API Gateway."
  type        = string
}

variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue."
  type        = string
}

variable "sqs_queue_id" {
  description = "The URL of the SQS queue."
  type        = string
}