variable "project_name" {}
variable "queue_arn" {}
variable "kms_key_arn" {}

resource "aws_iam_role" "this" {
  name = "${var.project_name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sqs:*"]
        Resource = var.queue_arn
      },
      {
        Effect = "Allow"
        Action = ["kms:Decrypt"]
        Resource = var.kms_key_arn
      }
    ]
  })
}

output "task_role_arn" {
  value = aws_iam_role.this.arn
}

resource "aws_iam_role" "execution" {
  name = "${var.project_name}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}