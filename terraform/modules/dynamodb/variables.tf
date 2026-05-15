variable "table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "hash_key" {
  description = "Chave de partição"
  type        = string
}

variable "range_key" {
  description = "Chave de classificação"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "Modo de cobrança (PROVISIONED ou PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Capacidade de leitura (se PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Capacidade de escrita (se PROVISIONED)"
  type        = number
  default     = 5
}

variable "attributes" {
  description = "Atributos da tabela"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = "Índices secundários globais"
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
  }))
  default = []
}

variable "enable_ttl" {
  description = "Habilitar TTL"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Nome do atributo para TTL"
  type        = string
  default     = "expiresAt"
}

variable "tags" {
  description = "Tags para a tabela"
  type        = map(string)
  default     = {}
}
