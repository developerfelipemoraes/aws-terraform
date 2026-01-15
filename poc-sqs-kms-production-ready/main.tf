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

resource "aws_ecs_cluster" "this" {
  name = "poc-ecs-consumer"
}

moved {
  from = module.ecs_consumer.aws_ecs_cluster.this
  to   = aws_ecs_cluster.this
}

module "network" {
  source       = "./modules/network"
  project_name = var.project_name_poc
}

module "ecs_consumer" {
  source          = "./modules/ecs-consumer"
  name            = "poc-ecs-consumer"
  cluster_id      = aws_ecs_cluster.this.id
  queue_url       = module.fila_b.queue_url
  task_role_arn   = module.iam_ecs.task_role_arn
  execution_role_arn = module.iam_ecs.execution_role_arn
  container_image = "${module.ecr_ecs_consumer.repository_url}:latest"
  region          = var.region
  subnets         = module.network.public_subnets
  security_groups = [module.network.sg_id]
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
  environment_variables = [
    {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    },
    {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    },
    {
      name  = "IMAGE_REPO_NAME"
      value = module.ecr_ecs_consumer.name
    },
    {
      name  = "IMAGE_TAG"
      value = "latest"
    },
    {
       name  = "CONTAINER_NAME"
       value = "app"
    },
    {
       name = "SERVICE_NAME"
       value = "poc-ecs-consumer"
    },
    {
       name = "CLUSTER_NAME"
       value = "poc-ecs-consumer"
    }
  ]
}

module "lambda_consumer" {
  source       = "./modules/lambda-consumer"
  project_name = "poc-lambda-consumer-fila-a"
  queue_arn    = module.fila_a.queue_arn
  kms_key_arn  = module.kms.key_arn
}
