output "flytrap_app_public_ip_for_DNS" {
  description = "The public IP address of the Flytrap application EC2 instance"
  value       = module.ec2.flytrap_app_public_ip_for_DNS
}

output "flytrap_bucket_name" {
  description = "The name of the Flytrap S3 bucket for storing sourcemaps"
  value       = module.lambda_configure.s3_bucket_name
}

output "flytrap_client_dashboard_url" {
  description = "Public IP address for the Flytrap client dashboard and lambda webhook"
  value       = module.ec2.ec2_url
}

output "default_admin_email_dashboard_login" {
  description = "Default admin password for Flytrap dashboard login"
  value       = "admin@admin.com"
}

output "default_admin_password_dashboard_login" {
  description = "Default admin password for Flytrap dashboard login"
  value       = "password123"
}