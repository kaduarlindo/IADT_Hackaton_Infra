output "lambda_execution_role_arn" {
  description = "ARN da role de execução Lambda"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_role_name" {
  description = "Nome da role de execução Lambda"
  value       = aws_iam_role.lambda_execution_role.name
}

output "api_gateway_role_arn" {
  description = "ARN da role API Gateway"
  value       = aws_iam_role.api_gateway_role.arn
}

output "api_gateway_role_name" {
  description = "Nome da role API Gateway"
  value       = aws_iam_role.api_gateway_role.name
}
