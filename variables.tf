# AWS
variable "aws_region" {
  type        = string
  description = "AWS Profile"
}

variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "hostname" {
  type        = string
  description = "hostname for website without domain"
}


## S3
variable "s3_index_document" {
  type        = string
  description = "File in bucket which should be index page"
  default     = "index.html"
}

variable "s3_error_document" {
  type        = string
  description = "File in bucket which should be error page"
  default     = "error.html"
}

variable "s3_acl" {
  type        = string
  description = "ACL for bucket. Possible values: private, public-read, public-read-write, aws-exec-read, authenticated-read, and log-delivery-write"
  //  default     = "public-read"
}

variable "s3_upload_files_path" {
  type        = string
  description = "Path to the folder with files for uploading to the s3 bucket"
}

variable "s3_max_age_seconds" {
  type        = number
  description = "Max age second for cors rules in S3 bucket"
  default     = 3000
}

variable "s3_versioning" {
  type        = bool
  description = "Whether to enable versioning on S3 or not. Default is true"
  default     = true
}

## Cloudfront

variable "cf_enabled" {
  description = "Whether if cf is enabled"
  type        = bool
  default     = true
}

variable "cf_is_ipv6_enabled" {
  description = "Whether if ipv6 is enabled"
  type        = bool
  default     = true
}

variable "cf_http_version" {
  description = "HTTP version for cf"
  type        = string
  default     = "http2"
}

### Default cache

variable "cf_cache_allowed" {
  description = "Allowed methods"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cf_cached_methods" {
  description = "Methods for caching"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cf_viewer_protocol_policy" {
  description = "Protocol policy"
  type        = string
  default     = "redirect-to-https"
}

variable "cf_compress" {
  description = "Do you want to enable compression"
  type        = bool
  default     = true
}

variable "cf_min_ttl" {
  description = "Min ttl for caching"
  type        = number
  default     = 0
}

variable "cf_default_ttl" {
  description = "Default ttl for caching"
  type        = number
  default     = 3600
}

variable "cf_max_ttl" {
  description = "Max ttl for caching"
  type        = number
  default     = 86400
}

### Restrictions

variable "cf_restricted_countries" {
  description = "List of countries for restriction"
  type        = list(string)
  default     = []
}

### logging
variable "cf_logging_bucket" {
  description = "Name of bucket with domain for logs (don't forget domain)"
  type        = string
}

variable "cf_logging_prefix" {
  description = "Prefix for storing logs"
  type        = string
}

variable "cf_include_cookies" {
  description = "Enabled cookies in logging"
  type        = bool
  default     = false
}

