resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "planetco-ai-website-oac"
  description                       = "OAC for planetco-ai-website S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "PlanetCo.ai static website (S3 origin via OAC)"
  default_root_object = "index.html"
  http_version        = "http2and3"
  price_class         = "PriceClass_100"

  # Aliases + ACM cert are added once the cert validates (after the IONOS NS
  # flip). For now we serve via the default *.cloudfront.net domain.
  aliases = []

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "s3-planetco-ai-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id

    connection_attempts = 3
    connection_timeout  = 10
  }

  default_cache_behavior {
    target_origin_id       = "s3-planetco-ai-website"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # Managed-CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    # Managed-SecurityHeadersPolicy
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
