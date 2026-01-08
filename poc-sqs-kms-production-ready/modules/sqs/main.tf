variable "name" {}
variable "kms_key_arn" {}

resource "aws_sqs_queue" "this" {
  name = var.name
  kms_master_key_id = var.kms_key_arn
}

output "queue_url" {
  value = aws_sqs_queue.this.id
}

output "queue_arn" {
  value = aws_sqs_queue.this.arn
}