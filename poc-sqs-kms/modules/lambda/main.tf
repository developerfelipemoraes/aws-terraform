variable "name" {}
variable "source_queue_arn" {}
variable "target_queue_arn" {}
variable "target_queue_url" {}
variable "kms_key_arn" {}

resource "aws_iam_role" "this" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:SendMessage"
        ]
        Resource = [var.source_queue_arn, var.target_queue_arn]
      },
      {
        Effect = "Allow"
        Action = ["kms:Decrypt"]
        Resource = var.kms_key_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  runtime       = "python3.11"
  handler       = "index.handler"
  role          = aws_iam_role.this.arn
  timeout       = 30
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  environment {
    variables = {
      TARGET_QUEUE_URL = var.target_queue_url
    }
  }
}

resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn = var.source_queue_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = 5
}