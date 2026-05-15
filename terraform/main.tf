terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "hackaton-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Módulo de IAM
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# Módulo de S3 para Upload
module "s3_upload" {
  source = "./modules/s3"

  bucket_name           = "${var.project_name}-uploads-${data.aws_caller_identity.current.account_id}"
  environment           = var.environment
  enable_versioning     = true
  enable_encryption     = true
  lambda_execution_role = module.iam.lambda_execution_role_arn

  tags = {
    Name = "${var.project_name}-upload-bucket"
  }
}

# Módulo de DynamoDB
module "dynamodb" {
  source = "./modules/dynamodb"

  table_name           = "${var.project_name}-documents"
  environment          = var.environment
  hash_key             = "documentId"
  range_key            = "timestamp"
  billing_mode         = "PAY_PER_REQUEST"
  enable_ttl           = true
  ttl_attribute_name   = "expiresAt"

  attributes = [
    {
      name = "documentId"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    },
    {
      name = "userId"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "UserIdIndex"
      hash_key        = "userId"
      range_key       = "timestamp"
      projection_type = "ALL"
    }
  ]
}

# Módulo de API
module "api" {
  source = "./modules/api"

  project_name            = var.project_name
  environment             = var.environment
  lambda_execution_role   = module.iam.lambda_execution_role_arn
  s3_bucket_name          = module.s3_upload.bucket_name
  dynamodb_table_name     = module.dynamodb.table_name
  api_gateway_role_arn    = module.iam.api_gateway_role_arn

  lambda_environment_variables = {
    S3_BUCKET_NAME      = module.s3_upload.bucket_name
    DYNAMODB_TABLE_NAME = module.dynamodb.table_name
    ENVIRONMENT         = var.environment
    LOG_LEVEL           = "INFO"
  }

  depends_on = [
    module.s3_upload,
    module.dynamodb,
    module.iam
  ]
}

# Módulo de CloudFront para Frontend
module "cloudfront" {
  source = "./modules/cloudfront"

  project_name       = var.project_name
  environment        = var.environment
  api_endpoint       = module.api.api_endpoint
  api_id             = module.api.api_id

  tags = {
    Name = "${var.project_name}-cdn"
  }
}

# Data source para obter ID da conta AWS
data "aws_caller_identity" "current" {}

# Outputs
output "api_endpoint" {
  description = "URL do endpoint da API"
  value       = module.api.api_endpoint
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 para uploads"
  value       = module.s3_upload.bucket_name
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = module.dynamodb.table_name
}

output "cloudfront_domain" {
  description = "Domínio do CloudFront para o frontend"
  value       = module.cloudfront.distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "ID da distribuição CloudFront"
  value       = module.cloudfront.distribution_id
}
