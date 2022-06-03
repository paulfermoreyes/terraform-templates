# Variable definitions
variable "app_name" {}
variable "app_fqdn" {}
variable "env" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "app_hosted_zone_id" {}
variable "default_tags" {
  type = object({
    Project     = string
    Owner       = string
    Team        = string
    Environment = string
  })
}

variable "region" {
  type        = string
  description = "AWS Deployment Region"
}
variable "availability_zones" {
  type        = list(any)
  description = "AWS Availability Zones"
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "private_subnets_cidr" {
  type        = list(any)
  default     = ["172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24"]
  description = "AWS Private Subnets List"
}
variable "public_subnets_cidr" {
  type        = list(any)
  default     = ["172.16.15.0/24", "172.16.25.0/24", "172.16.35.0/24"]
  description = "AWS Public Subnets List"
}

variable "linux_ami" {
  default = "ami-02a45d709a415958a"
}

variable "frontend_bucket_policy" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  description = "Bucket IAM Policy for S3 Bucket"
  default = {
    block_public_acls       = false
    block_public_policy     = true
    ignore_public_acls      = false
    restrict_public_buckets = true
  }
}

variable "acm_certificate_arn" {
  type = string
}

variable "cloudfront_config" {
  type = object({
    enabled                  = bool
    http_version             = string
    ipv6_enabled             = bool
    price_class              = string
    geo_restriction_location = list(string)
    geo_restriction_type     = string
    cert_protocol_version    = string
    cert_ssl_support_method  = string
    backend_origin = object({
      config = object({
        http_port              = number
        https_port             = number
        origin_protocol_policy = string
        origin_ssl_protocols   = list(string)
      })
    })
    backend_cache_behavior = object({
      path_pattern             = string
      allowed_methods          = list(string)
      viewer_protocol_policy   = string
      compress                 = bool
      smooth_streaming         = bool
      cache_policy_id          = string
      origin_request_policy_id = string
    })
    frontend_cache_behavior = object({
      path_pattern           = string
      allowed_methods        = list(string)
      viewer_protocol_policy = string
      compress               = bool
      smooth_streaming       = bool
      cache_policy_id        = string
    })
  })

  default = {
    backend_cache_behavior = {
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      compress                 = false
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      path_pattern             = "/api/*"
      smooth_streaming         = false
      viewer_protocol_policy   = "redirect-to-https"
    }
    backend_origin = {
      config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
    cert_protocol_version   = "TLSv1.2_2019"
    cert_ssl_support_method = "sni-only"
    enabled                 = true
    frontend_cache_behavior = {
      allowed_methods        = ["HEAD", "GET", "OPTIONS"]
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      compress               = false
      path_pattern           = "*"
      smooth_streaming       = false
      viewer_protocol_policy = "redirect-to-https"
    }
    geo_restriction_location = ["PH", "SG"]
    geo_restriction_type     = "whitelist"
    http_version             = "http2"
    ipv6_enabled             = false
    price_class              = "PriceClass_200"
  }
}

variable "cache_node_type" {
  type        = string
  default     = "cache.t2.micro"
  description = "Cache Node Type"
}
variable "db_name" {
  type        = string
  description = "DB name"
}
variable "db_instance_id" {
  type        = string
  description = "DB Instance ID"
}
variable "db_instance_class" {
  type        = string
  default     = "db.m5.large"
  description = "DB instance class"
}

variable "db_allocated_storage" {
  type        = number
  default     = 50
  description = "The size of the database (GiB)"
}

variable "db_username" {
  type        = string
  description = "Username for MySQL database access"
}

variable "db_password" {
  type        = string
  description = "Password MySQL database access"
}
