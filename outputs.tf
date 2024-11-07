output "public_api_gateway_url" {
  value = module.api_gateway.public_api_gateway_url
  description = "The public-facing URL for the API Gateway."
}