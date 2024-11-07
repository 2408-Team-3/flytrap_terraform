output "public_api_gateway_url" {
  value = "https://${aws_api_gateway_stage.stage.invoke_url}"
  description = "The public-facing URL for the API Gateway."
}

# move to variables?
output "ami" {
  description = "Amazon Machine Image (AMI) for Amazon Linux"
  type        = string
  default     = "ami-06b21ccaeff8cd686" # us-east-1
}