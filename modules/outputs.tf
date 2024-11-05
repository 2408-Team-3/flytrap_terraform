output "sqs_queue_arn" {
  value = aws_sqs_queue.flytrap_queue.arn
}

output "sqs_queue_name" {
  value = aws_sqs_queue.flytrap_queue.name
}

output "sqs_queue_id" {
  value = aws_sqs_queue.flytrap_queue.id
}