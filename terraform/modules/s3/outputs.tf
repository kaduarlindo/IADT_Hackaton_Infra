output "bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.upload_bucket.id
}

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.upload_bucket.arn
}

output "bucket_region" {
  description = "Região do bucket S3"
  value       = aws_s3_bucket.upload_bucket.region
}

output "log_bucket_name" {
  description = "Nome do bucket de logs"
  value       = aws_s3_bucket.log_bucket.id
}
