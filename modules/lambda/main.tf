resource "aws_lambda_function" "flytrap_lambda" {
  function_name = "flytrap_lambda_function"
  role          = var.lambda_iam_role_arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  filename      = "${path.root}/lib/flytrap_error_processor.zip"
  timeout       = 30

  environment {
    variables = {
      PGHOST      = var.db_endpoint
      PGPORT      = 5432
      PGDATABASE  = var.db_name
      SECRET_NAME = var.db_secret_name
      WEBHOOK_ENDPOINT = var.ec2_url
    }
  }

  vpc_config {
    subnet_ids          = var.private_subnet_ids
    security_group_ids  = [var.lambda_sg_id]
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  batch_size               = 5
  event_source_arn         = var.sqs_queue_arn
  function_name            = aws_lambda_function.flytrap_lambda.arn
  enabled                  = true
}