# AWS

variable "domain_name" {
  description = "The domain name for the website."
  type        = string
}

variable "hostname" {
  description = "hostname for website without domain"
  type        = string
}

# COMMON
variable "module_enabled" {
  description = "Whether to create resources within the module or not. Default is true."
  type        = bool
  default     = true
}

variable "module_depends_on" {
  description = "List of resources which module depends on"
  type = list(string)
  default = []
}

## S3

variable "s3_region" {
  description = "Region for backend S3 backend"
  type = string
}

variable "s3_index_document" {
  description = "File in bucket which should be index page"
  type        = string
  default     = "index.html"
}

variable "s3_acl" {
  description = "ACL for bucket. Possible values: private, public-read, public-read-write, aws-exec-read, authenticated-read, and log-delivery-write"
  type        = string
  default     = "public-read"
}

variable "s3_upload_files_path" {
  description = "Path to the folder with files for uploading to the s3 bucket"
  type        = string
}

variable "s3_versioning" {
  description = "Whether to enable versioning on S3 or not. Default is true"
  type        = bool
  default     = true
}

variable "s3_prevent_destroy" {
  description = "Whether to enable prevent destroying"
  type = bool
  default = true
}

## CloudFront

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
  description = "CloudFront viewer protocol policy"
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

variable "cf_geo_restrictions" {
  description = "Map for restriction"
  type = any
  default = {}
}

### logging
variable "cf_logging_bucket" {
  description = "Name of bucket with domain for logs (don't forget domain)"
  type        = string
}

variable "cf_logging_prefix" {
  description = "Prefix for storing logs"
  type        = string
  default = ""
}

variable "cf_include_cookies" {
  description = "Enabled cookies in logging"
  type        = bool
  default     = false
}

## Certificate
variable "cf_minimum_protocol_version" {
  description = "Minimum protocol version for SSL"
  type = string
  default = "TLSv1.2_2019"
}

variable "cf_ssl_support_method" {
  description = "SSL support method for CloudFront"
  type = string
  default = "sni-only"
}

# CloudFront Origin
variable "cf_origin_access_identity_comment" {
  description = "Comment for CloudFront Identity"
  type = string
  default = ""
}

