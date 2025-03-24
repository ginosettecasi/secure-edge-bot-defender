data "aws_iam_policy_document" "lambda_edge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_edge_role" {
  name               = "lambda-edge-bot-detector-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_assume_role.json
}

resource "aws_lambda_function" "bot_detector" {
  function_name = "bot-fingerprint-detector"
  role          = aws_iam_role.lambda_edge_role.arn
  handler       = "bot_fingerprint.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.bot_fingerprint.output_path
  publish       = true
  memory_size   = 128
  timeout       = 3

  source_code_hash = data.archive_file.bot_fingerprint.output_base64sha256
}

data "archive_file" "bot_fingerprint" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda/bot_fingerprint.zip"
}

resource "aws_cloudfront_distribution" "cdn" {
  # 🔁 Use the existing resource block you already have
  # Add this inside the default_cache_behavior:
  default_cache_behavior {
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.bot_detector.qualified_arn
      include_body = false
    }
  }
}
