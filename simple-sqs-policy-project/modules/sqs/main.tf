resource "aws_sqs_queue" "this" {
  name              = var.name
  kms_master_key_id = var.kms_master_key_id
}
