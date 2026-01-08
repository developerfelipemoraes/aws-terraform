variable "project_name_poc" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
