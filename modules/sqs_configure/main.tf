resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = var.sqs_queue_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action = "SQS:SendMessage"
      Resource = var.sqs_queue_arn
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = var.api_gateway_arn
        }
      }
    },
    {
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = [
        "SQS:ReceiveMessage",
        "SQS:DeleteMessage",
        "SQS:GetQueueAttributes"
      ]
      Resource = var.sqs_queue_arn
    }
    ]
  })
}