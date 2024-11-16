output "flytrap_sdk_url" {
  description = "The public-facing URL for the API Gateway."
  value       = module.api_gateway.public_api_gateway_url
}

output "flytrap_client_dashboard_url" {
  description = "Public IP address for the Flytrap client dashboard and lambda webhook"
  value       = module.ec2.ec2_url
}