output "flytrap_db_subnet_group" {
  value       = aws_db_subnet_group.flytrap_db_subnet_group.name
  description = "The DB subnet group used by Flytrap RDS"
}

output "flytrap_db_sg_id" {
  value       = aws_security_group.flytrap_db_sg.id
  description = "The security group ID for the Flytrap RDS instance"
}