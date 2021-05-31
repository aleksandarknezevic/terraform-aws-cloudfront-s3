output "bucket_name" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket[count.index].bucket
}

output "bucket_arn" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket[count.index].arn
}

output "bucket_acl" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket[count.index].acl
}

output "bucket_domain_name" {
  depends_on = [aws_s3_bucket.bucket]
  value = aws_s3_bucket.bucket[count.index].bucket_domain_name
}
