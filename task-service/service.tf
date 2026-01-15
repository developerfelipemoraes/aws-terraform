resource "aws_ecs_service" "service_poc_kms" {
  name    = "poc-sqs-kms-service"
  cluster = "ecs-app-sandbox"

  task_definition = aws_ecs_task_definition.service_poc_kms.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      "subnet-017e97ea2ef4bae53",
      "subnet-0ab200e2826bd5bdf"
    ]

    security_groups  = ["sg-08d3788bf5a504896"]
    assign_public_ip = false
  }

  depends_on = [
    aws_iam_role_policy.ecs_task_kms_policy
  ]
}