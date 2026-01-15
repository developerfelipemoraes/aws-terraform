resource "aws_ecs_task_definition" "service_poc_kms" {
  family                   = "service-poc-kms"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "sqs-worker"
      image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/sqs-worker:1.0.0"

      environment = [
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.poc_kms_queue.url
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/poc-sqs-kms"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}