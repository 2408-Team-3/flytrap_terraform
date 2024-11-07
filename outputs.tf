output "public_api_gateway_url" {
  value       = "https://${aws_api_gateway_stage.stage.invoke_url}"
  description = "The public-facing URL for the API Gateway."
}