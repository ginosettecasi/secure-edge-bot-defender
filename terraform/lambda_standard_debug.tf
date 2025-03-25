provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_exec" {
  name = "standard-lambda-bot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name,
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Zip Python code
data "archive_file" "bot_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda/bot_fingerprint_debug.zip"
}

resource "aws_lambda_function" "bot_debug" {
  function_name    = "bot-debug-detector",
  handler          = "bot_fingerprint.lambda_handler",
  runtime          = "python3.11",
  filename         = data.archive_file.bot_zip.output_path,
  source_code_hash = data.archive_file.bot_zip.output_base64sha256,

  role        = aws_iam_role.lambda_exec.arn,
  timeout     = 5,
  memory_size = 128
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "bot-detector-api",
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke",
  action        = "lambda:InvokeFunction",
  function_name = aws_lambda_function.bot_debug.arn,
  principal     = "apigateway.amazonaws.com",
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id,
  integration_type = "AWS_PROXY",
  integration_uri  = aws_lambda_function.bot_debug.invoke_arn
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id,
  route_key = "GET /",
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id,
  name        = "$default",
  auto_deploy = true
}
