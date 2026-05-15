# API Gateway REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-api"
  description = "API para ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

# Criando um arquivo ZIP placeholder para Lambda (necessário para deploy inicial)
data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "${path.module}/lambda_placeholder.zip"

  source {
    content  = "def handler(event, context):\n    return {'statusCode': 200, 'body': 'Hello from Lambda!'}\n"
    filename = "index.py"
  }
}

# Lambda para Upload
resource "aws_lambda_function" "upload_handler" {
  filename         = data.archive_file.lambda_placeholder.output_path
  function_name    = "${var.project_name}-upload-handler"
  role             = var.lambda_execution_role
  handler          = "src.lambda_handlers.upload_handler"
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  runtime          = "python3.11"

  environment {
    variables = merge(
      var.lambda_environment_variables,
      {
        FUNCTION_TYPE = "upload"
      }
    )
  }

  tags = {
    Name        = "${var.project_name}-upload-handler"
    Environment = var.environment
  }
}

# Lambda para Geração de PDF
resource "aws_lambda_function" "pdf_handler" {
  filename         = data.archive_file.lambda_placeholder.output_path
  function_name    = "${var.project_name}-pdf-handler"
  role             = var.lambda_execution_role
  handler          = "src.lambda_handlers.pdf_handler"
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  timeout          = 60
  memory_size      = var.lambda_memory_size
  runtime          = "python3.11"

  environment {
    variables = merge(
      var.lambda_environment_variables,
      {
        FUNCTION_TYPE = "pdf"
      }
    )
  }

  tags = {
    Name        = "${var.project_name}-pdf-handler"
    Environment = var.environment
  }
}

# Lambda para Operações CRUD
resource "aws_lambda_function" "crud_handler" {
  filename         = data.archive_file.lambda_placeholder.output_path
  function_name    = "${var.project_name}-crud-handler"
  role             = var.lambda_execution_role
  handler          = "src.lambda_handlers.crud_handler"
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  runtime          = "python3.11"

  environment {
    variables = merge(
      var.lambda_environment_variables,
      {
        FUNCTION_TYPE = "crud"
      }
    )
  }

  tags = {
    Name        = "${var.project_name}-crud-handler"
    Environment = var.environment
  }
}

# Recurso para Upload
resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.upload.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "upload_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.upload.id
  http_method      = aws_api_gateway_method.upload_post.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.upload_handler.invoke_arn
}

resource "aws_lambda_permission" "api_upload" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# Recurso para PDF
resource "aws_api_gateway_resource" "pdf" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "pdf"
}

resource "aws_api_gateway_method" "pdf_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.pdf.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "pdf_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.pdf.id
  http_method      = aws_api_gateway_method.pdf_post.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.pdf_handler.invoke_arn
}

resource "aws_lambda_permission" "api_pdf" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdf_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# Recurso para Documents (CRUD)
resource "aws_api_gateway_resource" "documents" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "documents"
}

# GET /documents
resource "aws_api_gateway_method" "documents_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.documents.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "documents_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.documents.id
  http_method      = aws_api_gateway_method.documents_get.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.crud_handler.invoke_arn
}

# POST /documents
resource "aws_api_gateway_method" "documents_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.documents.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "documents_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.documents.id
  http_method      = aws_api_gateway_method.documents_post.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.crud_handler.invoke_arn
}

# Resource para /documents/{id}
resource "aws_api_gateway_resource" "document_by_id" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.documents.id
  path_part   = "{id}"
}

# GET /documents/{id}
resource "aws_api_gateway_method" "document_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.document_by_id.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "document_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.document_by_id.id
  http_method      = aws_api_gateway_method.document_get.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.crud_handler.invoke_arn
}

# PUT /documents/{id}
resource "aws_api_gateway_method" "document_put" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.document_by_id.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "document_put" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.document_by_id.id
  http_method      = aws_api_gateway_method.document_put.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.crud_handler.invoke_arn
}

# DELETE /documents/{id}
resource "aws_api_gateway_method" "document_delete" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.document_by_id.id
  http_method      = "DELETE"
  authorization    = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_integration" "document_delete" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.document_by_id.id
  http_method      = aws_api_gateway_method.document_delete.http_method
  type             = "AWS_PROXY"
  integration_http_method = "POST"
  uri              = aws_lambda_function.crud_handler.invoke_arn
}

# Lambda permission para CRUD
resource "aws_lambda_permission" "api_crud" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crud_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# API Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [
    aws_api_gateway_integration.upload_post,
    aws_api_gateway_integration.pdf_post,
    aws_api_gateway_integration.documents_get,
    aws_api_gateway_integration.documents_post,
    aws_api_gateway_integration.document_get,
    aws_api_gateway_integration.document_put,
    aws_api_gateway_integration.document_delete
  ]
}

# API Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  xray_tracing_enabled = true
  logging_level        = "INFO"

  tags = {
    Name        = "${var.project_name}-api-${var.environment}"
    Environment = var.environment
  }
}

# CloudWatch Log Group para API
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-api-logs"
    Environment = var.environment
  }
}
