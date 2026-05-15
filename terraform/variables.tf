variable "aws_region" {
  description = "Região AWS para deploy"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "hackaton-platform"
}

variable "environment" {
  description = "Ambiente de deploy (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment deve ser dev, staging ou prod."
  }
}

variable "api_throttle_rate_limit" {
  description = "Rate limit por segundo para API"
  type        = number
  default     = 100
}

variable "api_throttle_burst_limit" {
  description = "Burst limit para API"
  type        = number
  default     = 200
}

variable "enable_cloudwatch_logs" {
  description = "Habilitar logs no CloudWatch"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)
  default = {
    Project = "HackatonPlatform"
    Owner   = "Platform Team"
  }
}
