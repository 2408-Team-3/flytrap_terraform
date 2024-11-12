output "public_api_gateway_url" {
  value = "${aws_api_gateway_stage.stage.invoke_url}"
}

output "api_gateway_execution_arn" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}"
}

output "api_gateway_usage_plan_id" {
  description = "API Gateway useage plan ID for API keys"
  value       = aws_api_gateway_usage_plan.usage_plan.id
}