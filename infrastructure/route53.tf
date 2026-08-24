resource "aws_route53_zone" "main" {
  name    = local.domain
  comment = "PlanetCo.ai website"
}

# Apex A record — currently still pointing at GitHub Pages IPs so the site
# stays up after the IONOS → Route 53 nameserver flip. Will be replaced with
# an alias to CloudFront once the ACM cert validates.
resource "aws_route53_record" "apex_gh_pages" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain
  type    = "A"
  ttl     = 300

  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "www_cname" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain_www
  type    = "CNAME"
  ttl     = 300
  records = [local.domain]
}

# ACM DNS validation records — required for the cert in us-east-1.
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = aws_route53_zone.main.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 300
  records         = [each.value.record]
  allow_overwrite = true
}
