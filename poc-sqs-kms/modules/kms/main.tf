variable "name" {}

resource "aws_kms_key" "this" {
  description             = "KMS key for SQS encryption"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.this.key_id
}

output "key_arn" {
  value = aws_kms_key.this.arn
}