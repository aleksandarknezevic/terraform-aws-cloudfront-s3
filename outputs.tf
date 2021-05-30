output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_acl" {
  value = aws_s3_bucket.bucket.acl
}

output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}
