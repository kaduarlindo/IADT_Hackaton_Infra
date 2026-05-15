variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "api_endpoint" {
  description = "URL do endpoint da API"
  type        = string
}

variable "api_id" {
  description = "ID da API Gateway"
  type        = string
}

variable "tags" {
  description = "Tags para CloudFront"
  type        = map(string)
  default     = {}
}
