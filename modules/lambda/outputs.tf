output "lambda_sg_id" {
  description = "The security group ID for Lambda access"
  value       = aws_security_group.lambda_sg.id
}