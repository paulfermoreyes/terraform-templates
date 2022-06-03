variable "env" {
  type = string
  default = "staging"
}

variable "app_url" {
    type = string
    description = "S3 Website URL"
}

variable "bucket_policy" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  description = "Bucket IAM Policy for S3 Bucket"
}

variable "versioning" {
  type        = string
  description = "Enable versioning of objects in S3 Bucket. eg. 'Enabled' or 'Disabled'"
}

variable "website_index_document" {
  type        = string
  description = "Index document for S3 Bucket Website Configuration"
  default     = "index.html"
}

variable "website_error_document" {
  type        = string
  description = "Error document for S3 Bucket Website Configuration"
  default     = "index.html"
}

