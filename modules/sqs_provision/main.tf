resource "aws_sqs_queue" "flytrap_queue" {
  name                       = var.queue_name
  visibility_timeout_seconds = 180
  message_retention_seconds  = 300
}