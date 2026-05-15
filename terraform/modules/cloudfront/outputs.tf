output "distribution_domain_name" {
  description = "Domínio da distribuição CloudFront"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_id" {
  description = "ID da distribuição CloudFront"
  value       = aws_cloudfront_distribution.main.id
}

output "frontend_bucket_name" {
  description = "Nome do bucket S3 do frontend"
  value       = aws_s3_bucket.frontend.id
}

output "origin_access_identity_path" {
  description = "Path da Origin Access Identity"
  value       = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
}
