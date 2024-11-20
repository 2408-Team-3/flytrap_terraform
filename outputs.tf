output "flytrap_sdk_url" {
  description = "The public-facing URL for the API Gateway."
  value       = module.api_gateway.public_api_gateway_url
}

output "flytrap_client_dashboard_url" {
  description = "Public IP address for the Flytrap client dashboard and lambda webhook"
  value       = module.ec2.ec2_url
}

output "aws_region" {
  value       = var.aws_region
  description = "The AWS region being used"
}

output "flytrap_app_public_ip_for_DNS" {
  value       = module.ec2.flytrap_app_public_ip_for_DNS
  description = "The public IP address of the Flytrap application EC2 instance"
}