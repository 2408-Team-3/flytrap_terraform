resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "api_gateway_sqs_policy" {
  name   = "api_gateway_sqs_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sqs:SendMessage"
      Resource = var.sqs_queue_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_sqs_attach" {
  policy_arn = aws_iam_policy.api_gateway_sqs_policy.arn
  role       = aws_iam_role.api_gateway_role.name
}

resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = var.base_api_path
}

resource "aws_api_gateway_resource" "errors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.api.id  # Link to the parent resource
  path_part   = var.errors_path
}

resource "aws_api_gateway_resource" "promises" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.api.id  # Link to the parent resource
  path_part   = var.promises_path
}

resource "aws_api_gateway_model" "errors_request_model" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name        = "ErrorsPostRequestModel"
  content_type = "application/json"
  schema = jsonencode({
    type = "object"
      properties = {
        data = {
          type = "object"
          properties = {
            error = {
              type = "object"
              properties = {
                name = { type = "string" }
                message = { type = "string" }
                stack = { type = "string" }
              }
              required = ["name", "message", "stack"]
            }
            handled = { type = "boolean" }
            timestamp = { type = "string", format = "date-time" }
            project_id = { type = "string" }
          }
          required = ["error", "handled", "timestamp", "project_id"]
        }
      }
  })
}

resource "aws_api_gateway_request_validator" "errors_request_validator" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name        = "ErrorsPostRequestValidator"
  validate_request_body = true
  validate_request_parameters = false
}

resource "aws_api_gateway_model" "promises_request_model" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name        = "PromisesPostRequestModel"
  content_type = "application/json"
  schema = jsonencode({
    type = "object"

    properties = {
      data = {
        type = "object"
        properties = {
          value = {
            oneOf = [
              { type = "string" },
              { type = "number" },
              { type = "object" },
              { type = "null" }
            ]
          }
          handled = { type = "boolean" }
          timestamp = { type = "string", format = "date-time" }
          project_id = { type = "string" }
        }
        required = ["value", "handled", "timestamp", "project_id"]
      }
    }
  })
}

resource "aws_api_gateway_request_validator" "promises_request_validator" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name        = "PromisesPostRequestValidator"
  validate_request_body = true
  validate_request_parameters = false
}