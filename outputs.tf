output "bucket_name" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.bucket
  description = "Name of the backend S3 bucket"
}

output "bucket_arn" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.arn
  description = "ARN of the backend S3 bucket"
}

output "bucket_acl" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.acl
  description = "ACL of the backend S3 bucket"
}

output "bucket_domain_name" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.bucket_domain_name
  description = "Domain name of the backend S3 bucket"
}
