resource "aws_acm_certificate" "website" {
  provider = aws.us_east_1

  domain_name               = local.domain
  subject_alternative_names = [local.domain_www]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"

  lifecycle {
    create_before_destroy = true
  }
}
