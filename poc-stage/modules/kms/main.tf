resource "aws_kms_key" "this" {
  description = "KMS key for SQS"
}

resource "aws_kms_alias" "this" {
  name          = "alias/kms-key-poc-stage"
  target_key_id = aws_kms_key.this.id
}

output "key_arn" {
  value = aws_kms_key.this.arn
}