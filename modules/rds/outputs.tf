output "flytrap_db_subnet_group" {
  value       = aws_db_subnet_group.flytrap_db_subnet_group.name
  description = "The DB subnet group used by Flytrap RDS"
}

output "flytrap_db_sg_id" {
  value       = aws_security_group.flytrap_db_sg.id
  description = "The security group ID for the Flytrap RDS instance"
}

output "flytrap_db_endpoint" {
  value       = aws_db_instance.flytrap_db.endpoint
  description = "The connection endpoint for the Flytrap RDS database"
}

output "db_name" {
  value       = aws_db_instance.flytrap_db.db_name
  description = "The name of the Flytrap RDS database"
}

output "db_secret_name" {
  value       = var.db_secret_name
  description = "The name of the AWS Secrets Manager secret containing RDS credentials"
}

output "db_secret_arn" {
  value       = data.aws_secretsmanager_secret.flytrap_db_secret.arn
  description = "The ARN of the AWS Secrets Manager secret containing RDS credentials"
}

# this is endpoint :port; delete?
output "db_endpoint" {
  value       = aws_db_instance.flytrap_db.endpoint
  description = "Connection endpoint for the Flytrap RDS database"
}

# this is endpoint with no port (for psql)
output "db_host" {
  value       = aws_db_instance.flytrap_db.address
  description = "Hostname for the Flytrap RDS database for psql"
}


output "db_arn" {
  value       = aws_db_instance.flytrap_db.arn
  description = "The ARN of the Flytrap RDS database instance"
}

output "rds_security_group_id" {
  value = aws_security_group.flytrap_db_sg.id
}