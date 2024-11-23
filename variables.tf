variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
}

variable "bucket_name" {
  description = "Base name for the Flytrap S3 sourcemaps bucket"
  type        = string
  default     = "flytrap-sourcemaps-bucket"
}