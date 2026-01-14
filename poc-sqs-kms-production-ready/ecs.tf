module "ecs_producer" {
  source = "github.com/escaletech/terraform-modules/modules/ecs-service-fargate"

  service_name = "poc-sqs-producer"
  cluster_id   = "ecs-poc-sqs-kms"

  desired_count = 1

  ########################################
  # 🔹 IMAGEM DO ECR
  ########################################
  container_definitions = jsonencode([
    {
      name      = "producer"
      image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/poc-sqs-producer:latest"
      essential = true

      environment = [
        {
          name  = "SQS_QUEUE_URL"
          value = module.poc-sqs-with-kms["queue-a"].queue_url
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/poc-sqs-producer"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "producer"
        }
      }
    }
  ])

  ########################################
  # 🔹 TASK ROLE — SQS + KMS
  ########################################
  task_role_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Enviar mensagens
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueUrl",
          "sqs:GetQueueAttributes"
        ]
        Resource = module.poc-sqs-with-kms["queue-a"].queue_arn
      },

      # KMS (necessário para SQS criptografado)
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = module.kms["queue-a"].key_arn
      }
    ]
  })

  ########################################
  # 🔹 EXECUTION ROLE (ECR + LOGS)
  ########################################
  execution_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}
