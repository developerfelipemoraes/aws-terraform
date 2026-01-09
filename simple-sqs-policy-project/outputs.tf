output "sqs_queue_url" {
  value       = aws_sqs_queue.this.id
  description = "The URL of the SQS queue"
}

output "sqs_queue_arn" {
  value       = aws_sqs_queue.this.arn
  description = "The ARN of the SQS queue"
}

output "kms_key_arn" {
  value       = aws_kms_key.this.arn
  description = "The ARN of the KMS key"
}

output "iam_policy_arn" {
  value       = aws_iam_policy.read_policy.arn
  description = "The ARN of the IAM policy to attach to Lambda or ECS roles"
}
