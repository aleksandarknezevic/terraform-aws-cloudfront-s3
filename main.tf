# Locals
locals {
  fqdn            = var.hostname == "" ? var.domain_name : join(".", [var.hostname, var.domain_name])
  logging_counter = var.cf_logging == {} ? [] : [""]
  content_type_map = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    svg  = "image/svg+xml",
    jpg  = "image/jpeg",
    ico  = "image/x-icon",
    png  = "image/png",
    gif  = "image/gif",
    pdf  = "application/pdf",
    txt  = "text/plain",
    json = "application/json",
    map  = "application/json"
  }
}

# S3 bucket
resource "aws_s3_bucket" "bucket" {

  bucket = replace(local.fqdn, ".", "-")
  acl    = var.s3_acl
  versioning {
    enabled = var.s3_versioning
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    "Name" = replace(local.fqdn, ".", "-")
  }

  depends_on = [var.module_depends_on]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "1"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cf-identity.iam_arn]
    }
  }
  statement {

    sid = "2"
    effect = "Deny"
    actions = [
      "s3:GetObject",
      "s3:PutObjectTagging"
    ]

    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/av-status"

      values = [
        "INFECTED"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy_attach" {

  bucket     = aws_s3_bucket.bucket.id
  policy     = data.aws_iam_policy_document.s3_policy.json
  depends_on = [var.module_depends_on]
}

resource "aws_s3_bucket_public_access_block" "bucket_block_public" {

  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

## Upload files
resource "aws_s3_bucket_object" "website" {
  for_each     = fileset(var.s3_upload_files_path, "**")
  bucket       = aws_s3_bucket.bucket.id
  key          = each.value
  source       = "${var.s3_upload_files_path}${each.value}"
  acl          = var.s3_acl
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
  etag         = filemd5("${var.s3_upload_files_path}${each.value}")
  tags = {
    "Name" = each.value
  }
  depends_on = [aws_s3_bucket.bucket]
}

# Get route53 zone_id
data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false
}

# SSL certificate
resource "aws_acm_certificate" "certificate" {
  provider                  = aws.virginia
  domain_name               = local.fqdn
  subject_alternative_names = [format("*.%s", local.fqdn)]
  validation_method         = "DNS"
  depends_on                = [var.module_depends_on]
}

## SSL certificate validation
resource "aws_route53_record" "validation" {
  provider = aws.virginia
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.id

  depends_on = [aws_acm_certificate.certificate]
}

resource "aws_acm_certificate_validation" "validation" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
  depends_on              = [aws_acm_certificate.certificate]
}

# CloudFront

resource "aws_cloudfront_origin_access_identity" "cf-identity" {

  comment    = var.cf_origin_access_identity_comment
  depends_on = [var.module_depends_on]
}

resource "aws_cloudfront_distribution" "website" {

  enabled             = var.cf_enabled
  is_ipv6_enabled     = var.cf_is_ipv6_enabled
  default_root_object = var.s3_index_document
  http_version        = var.cf_http_version
  default_cache_behavior {
    allowed_methods        = var.cf_cache_allowed
    cached_methods         = var.cf_cached_methods
    target_origin_id       = format("S3-%s", local.fqdn)
    viewer_protocol_policy = var.cf_viewer_protocol_policy
    compress               = var.cf_compress
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = var.cf_min_ttl
    default_ttl = var.cf_default_ttl
    max_ttl     = var.cf_max_ttl
  }

  aliases = [local.fqdn]

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = format("S3-%s", local.fqdn)

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf-identity.cloudfront_access_identity_path
    }
  }


  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.cf_geo_restrictions]

      content {
        restriction_type = lookup(geo_restriction.value, "restriction_type", "none")
        locations        = lookup(geo_restriction.value, "locations", [])
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    ssl_support_method       = var.cf_ssl_support_method
    minimum_protocol_version = var.cf_minimum_protocol_version
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 300
    response_code         = 200
    response_page_path    = format("/%s", var.s3_index_document)
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 300
    response_code         = 200
    response_page_path    = format("/%s", var.s3_index_document)
  }

  web_acl_id = var.cf_web_acl_id

  dynamic "logging_config" {
    for_each = local.logging_counter
    content {
      bucket          = var.cf_logging["bucket"]
      include_cookies = lookup(var.cf_logging, "include_cookies", false)
      prefix          = lookup(var.cf_logging, "prefix", "/")
    }
  }

  tags = {
    Name = local.fqdn
  }

  depends_on = [var.module_depends_on]

}

# Route53 record

resource "aws_route53_record" "alias" {
  name    = local.fqdn
  type    = "A"
  zone_id = data.aws_route53_zone.zone.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
  }

  depends_on = [var.module_depends_on]

}
