data "aws_secretsmanager_secret" "flytrap_db_secret" {
  name = var.db_secret_name
}

data "aws_secretsmanager_secret_version" "flytrap_db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.flytrap_db_secret.id
}

locals {
  db_user     = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["username"]
  db_password = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["password"]
}

resource "aws_lambda_function" "flytrap_lambda" {
  function_name = "flytrap_lambda_function"
  role          = var.lambda_iam_role_arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  filename      = "${path.root}/lib/flytrap_error_processor.zip"
  timeout       = 300

  environment {
    variables = {
      PGHOST           = var.db_host
      PGPORT           = 5432
      PGDATABASE       = var.db_name
      PGUSER           = local.db_user
      PGPASSWORD       = local.db_password
      WEBHOOK_ENDPOINT = var.ec2_url
      S3_BUCKET_NAME   = var.s3_bucket_name
      REGION           = var.region
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