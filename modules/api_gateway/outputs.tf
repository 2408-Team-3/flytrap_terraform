# public-facing api_gateway_url (for use in skds?)
output "public_api_gateway_url" {
  value = "${aws_api_gateway_stage.stage.invoke_url}
}

# for internal permissions with sqs
output "api_gateway_execution_arn" {
  value = "${aws_api_gateway_rest_api.api.execution_arn}"
}