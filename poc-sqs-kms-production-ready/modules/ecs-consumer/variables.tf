variable "name" {}
variable "queue_url" {}
variable "task_role_arn" {}
variable "subnets" { type = list(string) }
variable "security_groups" { type = list(string) }