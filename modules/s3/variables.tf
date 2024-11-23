variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "lambda_iam_role_arn" {
  description = "The ARN of the Lambda IAM role that requires access to the S3 bucket"
  type        = string
}

variable "current_user_arn" {
  description = "The ARN of the current user"
  type        = string
}