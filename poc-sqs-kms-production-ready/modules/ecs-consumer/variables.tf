variable "name" {}
variable "cluster_id" {}
variable "queue_url" {}
variable "task_role_arn" {}
variable "execution_role_arn" {}
variable "container_image" {}
variable "region" {}
variable "subnets" { type = list(string) }
variable "security_groups" { type = list(string) }