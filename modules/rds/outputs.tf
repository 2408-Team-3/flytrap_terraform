output "flytrap_db_sg_id" {
  description = "The security group ID for the Flytrap RDS instance"
  value       = aws_security_group.flytrap_db_sg.id
}

output "db_name" {
  description = "The name of the Flytrap RDS database"
  value       = aws_db_instance.flytrap_db.db_name
}

output "db_secret_name" {
  description = "The name of the AWS Secrets Manager secret containing RDS credentials"
  value       = var.db_secret_name
}

output "db_secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret containing RDS credentials"
  value       = data.aws_secretsmanager_secret.flytrap_db_secret.arn
}

output "db_host" {
  description = "Hostname for the Flytrap RDS database for psql"
  value       = aws_db_instance.flytrap_db.address
}

output "db_arn" {
  description = "The ARN of the Flytrap RDS database instance"
  value       = aws_db_instance.flytrap_db.arn
}

output "rds_security_group_id" {
  description = "RDS secutiry group ID for update_security_group_rules module"
  value       = aws_security_group.flytrap_db_sg.id
}