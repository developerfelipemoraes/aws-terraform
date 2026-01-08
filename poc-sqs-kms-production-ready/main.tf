variable "aws_region" {
  description = "AWS region"
  type        = string
}



module "kms" {
  source       = "./modules/kms"
  
}

module "fila_a" {
  source       = "./modules/sqs"
  name         = "fila-a"
  kms_key_arn = module.kms.key_arn
}

module "fila_b" {
  source       = "./modules/sqs"
  name         = "fila-b"
  kms_key_arn = module.kms.key_arn
}

module "iam_ecs" {
  source       = "./modules/iam-ecs"
  project_name = var.project_name_poc
  queue_arn    = module.fila_b.queue_arn
  kms_key_arn  = module.kms.key_arn
}

module "ecs_consumer" {
  source          = "./modules/ecs-consumer"
  name            = "poc-ecs-consumer"
  queue_url       = module.fila_b.queue_url
  task_role_arn   = module.iam_ecs.task_role_arn
  subnets         = ["subnet-private-poc-sqs"]
  security_groups = ["sg-poc-sqs"]
}

module "ecr_ecs_consumer" {
  source = "./modules/ecr"

  name        = "poc-ecs-consumer"
  max_images = 10
}


module "codebuild_ecs_consumer" {
  source = "./modules/codebuild"

  project_name     = "ecs-consumer-build"
  github_repo_url  = "https://github.com/developerfelipemoraes/poc-ecs-python"
}
