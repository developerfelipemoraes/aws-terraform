module "kms" {
  source = "./modules/kms"
  name   = "poc-sqs-key"
}

module "fila_a" {
  source      = "./modules/sqs"
  name        = "fila-a"
  kms_key_arn = module.kms.key_arn
}

module "fila_b" {
  source = "./modules/sqs"
  name   = "fila-b"
}

module "lambda" {
  source            = "./modules/lambda"
  name              = "poc-lambda"
  source_queue_arn  = module.fila_a.queue_arn
  target_queue_arn  = module.fila_b.queue_arn
  target_queue_url  = module.fila_b.queue_url
  kms_key_arn       = module.kms.key_arn
}