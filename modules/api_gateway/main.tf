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

resource "aws_api_gateway_method" "post_errors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.errors.id
  http_method   = "POST"
  authorization = "NONE" # ("API_KEY") NONE allows SDKs to send requests without authentication tokens or IAM permissions

  request_models = {
    "application/json" = aws_api_gateway_model.errors_request_model.name
  }

  request_validator_id = aws_api_gateway_request_validator.errors_request_validator.id
}

resource "aws_api_gateway_method" "post_promises" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.promises.id
  http_method   = "POST"
  authorization = "NONE" # ("API_KEY") NONE allows SDKs to send requests without authentication tokens or IAM permissions

  request_models = {
    "application/json" = aws_api_gateway_model.promises_request_model.name
  }

  request_validator_id = aws_api_gateway_request_validator.promises_request_validator.id
}

resource "aws_api_gateway_method_response" "errors_post_200_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.errors.id
  http_method = aws_api_gateway_method.post_errors.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods"  = "'POST'"
    "method.response.header.Access-Control-Allow-Headers"  = "'Content-Type'"
  }
}

resource "aws_api_gateway_method_response" "errors_post_400_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.errors.id
  http_method = aws_api_gateway_method.post_errors.http_method
  status_code = "400"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods"  = "'POST'"
    "method.response.header.Access-Control-Allow-Headers"  = "'Content-Type'"
  }
}

resource "aws_api_gateway_method_response" "errors_post_500_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.errors.id
  http_method = aws_api_gateway_method.post_errors.http_method
  status_code = "500"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods"  = "'POST'"
    "method.response.header.Access-Control-Allow-Headers"  = "'Content-Type'"
  }
}

resource "aws_api_gateway_method_response" "promises_post_200_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.promises.id
  http_method = aws_api_gateway_method.post_promises.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods"  = "'POST'"
    "method.response.header.Access-Control-Allow-Headers"  = "'Content-Type'"
  }
}

resource "aws_api_gateway_method_response" "promises_post_400_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.promises.id
  http_method = aws_api_gateway_method.post_promises.http_method
  status_code = "400"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods"  = "'POST'"
    "method.response.header.Access-Control-Allow-Headers"  = "'Content-Type'"
  }
}

resource "aws_api_gateway_method_response" "promises_post_500_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.promises.id
  http_method = aws_api_gateway_method.post_promises.http_method
  status_code = "500"

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods"  = "'POST'"
    "method.response.header.Access-Control-Allow-Headers"  = "'Content-Type'"
  }
}

resource "aws_api_gateway_integration" "sqs_integration_errors" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.errors.id
  http_method             = aws_api_gateway_method.post_errors.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${var.account_id}/${var.sqs_queue_name}"

  credentials             = aws_iam_role.api_gateway_role.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

resource "aws_api_gateway_integration" "sqs_integration_promises" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.promises.id
  http_method             = aws_api_gateway_method.post_promises.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${var.account_id}/${var.sqs_queue_name}"

  credentials             = aws_iam_role.api_gateway_role.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
}

resource "aws_api_gateway_integration_response" "sqs_200_response_errors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.errors.id
  http_method = aws_api_gateway_method.post_errors.http_method
  status_code = "200"
  selection_pattern = "^2[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"Successfully processed message\"}"
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_integration_response" "sqs_400_response_errors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.errors.id
  http_method = aws_api_gateway_method.post_errors.http_method
  status_code = "400"
  selection_pattern = "^4[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"Oversized or invalid request\"}"
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_integration_response" "sqs_500_response_errors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.errors.id
  http_method = aws_api_gateway_method.post_errors.http_method
  status_code = "500"
  selection_pattern = "^5[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"Internal server error while processing message\"}"
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_integration_response" "sqs_200_response_promises" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.promises.id
  http_method = aws_api_gateway_method.post_promises.http_method
  status_code = "200"
  selection_pattern = "^2[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"Successfully processed message\"}"
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_integration_response" "sqs_400_response_promises" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.promises.id
  http_method = aws_api_gateway_method.post_promises.http_method
  status_code = "400"
  selection_pattern = "^4[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"Oversized or invalid request\"}"
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_integration_response" "sqs_500_response_promises" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.promises.id
  http_method = aws_api_gateway_method.post_promises.http_method
  status_code = "500"
  selection_pattern = "^5[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"Internal server error while processing message\"}"
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on  = [
    aws_api_gateway_rest_api.api,
    aws_api_gateway_resource.errors,
    aws_api_gateway_resource.promises,
    aws_api_gateway_method.post_errors,
    aws_api_gateway_method.post_promises,
    aws_api_gateway_integration.sqs_integration_errors,
    aws_api_gateway_integration.sqs_integration_promises
  ]
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name
}