data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy" "lambda_permissions_policy" {
  name        = "${var.lambda_name}-permissions-policy"
  description = "Policy to allow Lambda to access SQS, Secrets Manager, RDS, and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = var.sqs_queue_arn
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = var.db_secret_arn
      },
      {
        Action = [
          "rds:Connect",
          "rds:DescribeDBInstances",
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement"
        ]
        Effect   = "Allow"
        Resource = var.db_instance_arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_permissions_attachment" {
  policy_arn = aws_iam_policy.lambda_permissions_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.lambda_name}-sg"
  description = "Allow Lambda functions to connect to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
  }
}

resource "aws_lambda_function" "flytrap_lambda" {
  function_name = "flytrap_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime # make sure this matches
  filename      = "${path.root}/lib/flytrap_error_processor.zip"

  environment = {
    PGHOST      = var.db_endpoint
    PGPORT      = 5432
    PGDATABASE  = var.db_name
    SECRET_NAME = var.db_secret_name
  }

  vpc_config {
    subnet_ids          = var.private_subnet_ids
    security_group_ids  = [aws_security_group.lambda_sg.id]
  }
}