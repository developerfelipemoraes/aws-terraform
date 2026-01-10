resource "aws_kms_key" "this" {
  description             = "KMS key for SQS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "this" {
  name          = "alias/simple-project-key"
  target_key_id = aws_kms_key.this.id
}
