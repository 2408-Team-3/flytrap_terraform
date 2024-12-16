output "lambda_sg_id" {
  description = "The security group ID for Lambda access"
  value       = aws_security_group.lambda_sg.id
}

output "lambda_iam_role_arn" {
  description = "ARN for the lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "s3_bucket_name" {
  description = "Full name for the Flytrap sourcemaps S3 bucket"
  value       = local.s3_bucket_name
}
