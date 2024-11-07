variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1" # change as needed
}

variable "ami" {
  description = "Amazon Machine Image (AMI) for Amazon Linux"
  type        = string
  default     = "ami-06b21ccaeff8cd686" # us-east-1
}