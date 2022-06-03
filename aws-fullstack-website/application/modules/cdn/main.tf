resource "aws_route53_record" "name" {
  name = var.app_fqdn
  type = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
  zone_id = var.route_zone_id
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_oai" {
  comment = "${var.app_name} ${var.env} Cloudfront OAI"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled         = var.cloudfront_config.enabled
  is_ipv6_enabled = var.cloudfront_config.ipv6_enabled
  comment         = "${var.app_name} Cloudfront Distribution [${var.env}]"
  aliases         = [var.app_fqdn]

  # frontend origin
  origin {
    domain_name = var.s3_bucket.bucket_domain_name
    origin_id   = "${var.app_name}-${var.env}-frontend-origin"
    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.cloudfront_oai.id}"
    }
  }

  # backend origin
  origin {
    domain_name = var.backend_lb_fqdn
    origin_id   = "${var.app_name}-${var.env}-backend-origin"

    custom_origin_config {
      http_port              = var.cloudfront_config.backend_origin.config.http_port
      https_port             = var.cloudfront_config.backend_origin.config.https_port
      origin_protocol_policy = var.cloudfront_config.backend_origin.config.origin_protocol_policy
      origin_ssl_protocols   = var.cloudfront_config.backend_origin.config.origin_ssl_protocols
    }
  }

  # Frontend
  default_cache_behavior {
    allowed_methods        = var.cloudfront_config.frontend_cache_behavior.allowed_methods
    cached_methods         = var.cloudfront_config.frontend_cache_behavior.allowed_methods
    cache_policy_id        = var.cloudfront_config.frontend_cache_behavior.cache_policy_id #"658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    target_origin_id       = "${var.app_name}-${var.env}-frontend-origin"
    viewer_protocol_policy = var.cloudfront_config.frontend_cache_behavior.viewer_protocol_policy
  }

  # Cache behavior with precedence 0
  # Backend
  ordered_cache_behavior {
    path_pattern             = var.cloudfront_config.backend_cache_behavior.path_pattern
    allowed_methods          = var.cloudfront_config.backend_cache_behavior.allowed_methods
    cached_methods           = ["HEAD", "GET", "OPTIONS"]
    cache_policy_id          = var.cloudfront_config.backend_cache_behavior.cache_policy_id #"4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id = var.cloudfront_config.backend_cache_behavior.origin_request_policy_id
    target_origin_id         = "${var.app_name}-${var.env}-backend-origin"
    viewer_protocol_policy   = var.cloudfront_config.backend_cache_behavior.viewer_protocol_policy
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 10
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_config.geo_restriction_type
      locations        = var.cloudfront_config.geo_restriction_location
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = var.cloudfront_config.cert_protocol_version
    ssl_support_method       = var.cloudfront_config.cert_ssl_support_method
  }
}

data "aws_iam_policy_document" "cloudfront_s3_access" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${ aws_cloudfront_origin_access_identity.cloudfront_oai.id }"
      ]
    }

    # Permissions to allow for Cloudfront
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${var.s3_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = var.s3_bucket.id
  policy = data.aws_iam_policy_document.cloudfront_s3_access.json
}


