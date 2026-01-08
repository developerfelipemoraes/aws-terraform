variable "name" {
  description = "Nome do repositório ECR"
  type        = string
}

variable "scan_on_push" {
  description = "Habilitar scan de imagem no push"
  type        = bool
  default     = true
}

variable "max_images" {
  description = "Quantidade máxima de imagens a manter"
  type        = number
  default     = 10
}
