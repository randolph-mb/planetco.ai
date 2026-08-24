output "route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "route53_nameservers" {
  description = "Set these as NS records at your registrar (IONOS)."
  value       = aws_route53_zone.main.name_servers
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.website.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.website.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.website.domain_name
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}
