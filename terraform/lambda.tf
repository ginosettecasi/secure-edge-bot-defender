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
  name               = "lambda-edge-bot-detector-role-${random_id.id.hex}"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_assume_role.json
}

resource "aws_iam_role_policy" "lambda_logging" {
  name = "lambda-edge-logging"
  role = aws_iam_role.lambda_edge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "bot_fingerprint" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda/bot_fingerprint.zip"
}

resource "aws_lambda_function" "bot_detector" {
  function_name = "bot-fingerprint-detector-${random_id.id.hex}"
  role          = aws_iam_role.lambda_edge_role.arn
  handler       = "bot_fingerprint.lambda_handler"
  runtime       = "python3.11"
  filename      = data.archive_file.bot_fingerprint.output_path
  publish       = true
  memory_size   = 128
  timeout       = 3

  source_code_hash = data.archive_file.bot_fingerprint.output_base64sha256
}

resource "null_resource" "force_lambda_redeploy" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo 'Forcing Lambda re-deploy...'"
  }

  depends_on = [aws_lambda_function.bot_detector]
}
