aws_region   = "us-east-1"
project_name = "hackaton-platform"
environment  = "dev"

api_throttle_rate_limit = 100
api_throttle_burst_limit = 200

enable_cloudwatch_logs = true
log_retention_days     = 30

tags = {
  Project     = "HackatonPlatform"
  Owner       = "Platform Team"
  CostCenter  = "Engineering"
  ManagedBy   = "Terraform"
}
