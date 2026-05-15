output "table_name" {
  description = "Nome da tabela DynamoDB"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = aws_dynamodb_table.main.arn
}

output "stream_arn" {
  description = "ARN do stream do DynamoDB"
  value       = aws_dynamodb_table.main.stream_arn
}

output "stream_view_type" {
  description = "Tipo de visualização do stream"
  value       = aws_dynamodb_table.main.stream_specification[0].stream_view_type
}
