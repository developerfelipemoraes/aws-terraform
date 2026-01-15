variable "project_name" {
  type = string
}

variable "github_repo_url" {
  type = string
}

variable "log_group_name" {
  type    = string
  default = "/codebuild/ecs-consumer-build"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
