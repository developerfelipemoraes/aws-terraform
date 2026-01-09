
module "kms" {
  source = "./modules/kms"
}

module "fila_c" {
  source = "./modules/sqs"
  name   = "fila-c"
  # kms_key_arn is optional and defaults to null
}

module "lambda_consumer" {
  source       = "./modules/lambda-consumer"
  project_name = "poc-lambda-consumer-fila-c"
  queue_arn    = module.fila_c.queue_arn
  # kms_key_arn is optional and defaults to null
}
