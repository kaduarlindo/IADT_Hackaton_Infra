variable "bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "enable_versioning" {
  description = "Habilitar versionamento de objetos"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Habilitar encriptação"
  type        = bool
  default     = true
}

variable "lambda_execution_role" {
  description = "ARN da role de execução Lambda"
  type        = string
}

variable "tags" {
  description = "Tags para o bucket"
  type        = map(string)
  default     = {}
}
