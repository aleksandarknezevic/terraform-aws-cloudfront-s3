output "bucket_name" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.bucket
}

output "bucket_arn" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.arn
}

output "bucket_acl" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.acl
}

output "bucket_domain_name" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket.bucket_domain_name
}
