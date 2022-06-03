resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.app_url
}

resource "aws_s3_bucket_ownership_controls" "frontend_bucket_ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "frontend_bucket_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id
  block_public_acls = var.bucket_policy.block_public_acls
  block_public_policy = var.bucket_policy.block_public_policy
  ignore_public_acls = var.bucket_policy.ignore_public_acls
  restrict_public_buckets = var.bucket_policy.restrict_public_buckets
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website_config" {
  bucket = aws_s3_bucket.frontend_bucket.id
  index_document {
    suffix = var.website_index_document
  }

  error_document {
    key = var.website_error_document
  }
}
