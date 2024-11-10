output "ec2_url" {
  description = "EC2 url for accessing frontend and lambda webhook endpoint"
  value       = aws_instance.flytrap_app.public_dns
}

output "ec2_security_group_id" {
  description = "EC2 security group ID"
  value = aws_security_group.flytrap_app_sg.id
}