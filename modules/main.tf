resource "aws_sqs_queue" "flytrap_queue" {
  name = var.queue_name
}