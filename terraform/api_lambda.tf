provider "aws" {
  region = "us-east-1"
}

# IAM Role
resource "aws_iam_role" "api_lambda_role" {
  name = "api-bot-detector-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Logging Policy
resource "aws_iam_role_policy" "api_lambda_logging" {
  name = "lambda-logging"
  role = aws_iam_role.api_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Package Lambda
data "archive_file" "bot_fingerprint_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda/bot_fingerprint.zip"
}

# Lambda Function
resource "aws_lambda_function" "bot_fingerprint_api" {
  function_name = "api-bot-detector"
  filename      = data.archive_file.bot_fingerprint_zip.output_path
  source_code_hash = data.archive_file.bot_fingerprint_zip.output_base64sha256

  handler = "bot_fingerprint.lambda_handler"
  runtime = "python3.11"
  role    = aws_iam_role.api_lambda_role.arn
  timeout = 3
  memory_size = 128
}

# API Gateway
resource "aws_apigatewayv2_api" "bot_api" {
  name          = "bot-detector-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.bot_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.bot_fingerprint_api.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.bot_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.bot_api.id
  name        = "prod"
  auto_deploy = true
}

# Lambda Permission to Allow API Gateway to Invoke
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bot_fingerprint_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.bot_api.execution_arn}/*/*"
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.bot_api.api_endpoint
}
