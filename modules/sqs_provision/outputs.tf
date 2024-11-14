output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.flytrap_queue.arn
}

output "sqs_queue_name" {
  description = "SQS queue name"
  value       = aws_sqs_queue.flytrap_queue.name
}

output "sqs_queue_id" {
  description = "SQS queue ID"
  value       = aws_sqs_queue.flytrap_queue.id
}