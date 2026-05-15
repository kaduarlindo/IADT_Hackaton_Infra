output "api_endpoint" {
  description = "URL do endpoint da API"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_id" {
  description = "ID da API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "upload_lambda_function_name" {
  description = "Nome da função Lambda de upload"
  value       = aws_lambda_function.upload_handler.function_name
}

output "pdf_lambda_function_name" {
  description = "Nome da função Lambda de PDF"
  value       = aws_lambda_function.pdf_handler.function_name
}

output "crud_lambda_function_name" {
  description = "Nome da função Lambda CRUD"
  value       = aws_lambda_function.crud_handler.function_name
}
