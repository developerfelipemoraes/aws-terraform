provider "aws" {
  region = "us-east-1"
}

variable "project_name" {
  default = "simple-project"
}

# KMS Key for SQS Encryption
resource "aws_kms_key" "this" {
  description             = "KMS key for SQS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.this.id
}

# SQS Queue with KMS Encryption
resource "aws_sqs_queue" "this" {
  name              = "${var.project_name}-queue"
  kms_master_key_id = aws_kms_key.this.arn
}

# IAM Policy for Consumers (Lambda/ECS)
resource "aws_iam_policy" "read_policy" {
  name        = "${var.project_name}-read-policy"
  description = "Policy to allow reading from SQS and decrypting with KMS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowSQSRead"
        Effect   = "Allow"
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.this.arn
      },
      {
        Sid      = "AllowKMSDecrypt"
        Effect   = "Allow"
        Action   = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.this.arn
      }
    ]
  })
}
