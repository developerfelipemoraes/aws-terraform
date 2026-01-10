provider "aws" {
  region = "us-east-1"
}

module "kms" {
  source = "./modules/kms"
}

module "fila_a" {
  source            = "./modules/sqs"
  name              = "fila-a"
  kms_master_key_id = module.kms.key_arn
}

module "fila_b" {
  source            = "./modules/sqs"
  name              = "fila-b"
  kms_master_key_id = module.kms.key_arn
}

module "fila_c" {
  source = "./modules/sqs"
  name   = "fila-c"
}

# Policy for KMS Key Access (as requested to be split)
module "kms_key_policy" {
  source      = "./modules/policy"
  name        = "simple-project-kms-key-policy"
  kms_key_arn = module.kms.key_arn
}

# Policy for SQS Queue Access
module "sqs_queue_policy" {
  source     = "./modules/policy"
  name       = "simple-project-sqs-queue-policy"
  queue_arns = [
    module.fila_a.queue_arn,
    module.fila_b.queue_arn,
    module.fila_c.queue_arn
  ]
}
