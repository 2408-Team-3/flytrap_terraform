output "public_api_gateway_url" {
  value       = module.api_gateway.public_api_gateway_url
  description = "The public-facing URL for the API Gateway."
}

output "db_user" {
  value     = module.ec2.db_user
  sensitive = true
  description = "The database user for the RDS instance (sensitive)"
}

output "db_host" {
  value       = module.rds.db_host
  description = "Hostname for the Flytrap RDS database for psql"
}

output "db_name" {
  value       = module.rds.db_name
  description = "The name of the Flytrap RDS database"
}

output "db_password" {
  value     = module.ec2.db_password
  sensitive = true
  description = "The database password for the RDS instance (sensitive)"
}

output "aws_region" {
  value       = var.aws_region
  description = "The AWS region where resources are deployed"
}

output "api_gateway_usage_plan_id" {
  value       = module.api_gateway.api_gateway_usage_plan_id
  description = "The API Gateway usage plan ID for API keys."
}