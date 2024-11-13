output "ec2_url" {
  description = "EC2 url for accessing frontend and lambda webhook endpoint"
  value       = "http://${aws_instance.flytrap_app.public_dns}"
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.flytrap_app_sg.id
}

output "db_user" {
  value     = local.db_user
  sensitive = true
  description = "The database user for the RDS instance (sensitive)"
}

output "db_host" {
  value       = var.db_host
  description = "Hostname for the Flytrap RDS database for psql"
}

output "db_name" {
  value       = var.db_name
  description = "The name of the Flytrap RDS database"
}

output "db_password" {
  value     = local.db_password
  sensitive = true
  description = "The database password for the RDS instance (sensitive)"
}

output "aws_region" {
  value       = var.aws_region
  description = "The AWS region where resources are deployed"
}

output "api_gateway_usage_plan_id" {
  value       = var.api_gateway_usage_plan_id
  description = "The API Gateway usage plan ID for API keys."
}
