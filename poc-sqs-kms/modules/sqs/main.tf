variable "name" {}
variable "kms_key_arn" {
  default = null
}

resource "aws_sqs_queue" "this" {
  name                              = var.name
  kms_master_key_id                 = var.kms_key_arn
  kms_data_key_reuse_period_seconds = var.kms_key_arn != null ? 300 : null
}

output "queue_url" {
  value = aws_sqs_queue.this.id
}

output "queue_arn" {
  value = aws_sqs_queue.this.arn
}