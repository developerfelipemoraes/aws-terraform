resource "aws_sqs_queue" "poc_kms_queue" {
  name = "poc-sqs-kms-queue"

  kms_master_key_id                 = aws_kms_key.sqs_kms.arn
  kms_data_key_reuse_period_seconds = 300
}