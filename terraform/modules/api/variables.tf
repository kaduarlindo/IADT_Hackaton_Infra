variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "lambda_execution_role" {
  description = "ARN da role de execução Lambda"
  type        = string
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
}

variable "api_gateway_role_arn" {
  description = "ARN da role API Gateway"
  type        = string
}

variable "lambda_environment_variables" {
  description = "Variáveis de ambiente para Lambda"
  type        = map(string)
  default     = {}
}

variable "lambda_timeout" {
  description = "Timeout em segundos para Lambda"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Tamanho de memória em MB para Lambda"
  type        = number
  default     = 512
}
