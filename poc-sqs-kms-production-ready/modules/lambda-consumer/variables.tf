variable "queue_arn" {
  description = "The ARN of the SQS queue to read from"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the SQS queue"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "poc-lambda-consumer"
}
