# PlanetCo.ai Infrastructure

Terraform manages all AWS resources for https://planetco.ai.

## Stack

- **Route 53** — hosted zone, DNS records, ACM validation
- **ACM** (us-east-1) — TLS cert for `planetco.ai` + `www.planetco.ai`
- **S3** — private website bucket (origin)
- **CloudFront** — CDN + HTTPS, S3 origin via OAC
- **IAM** — OIDC provider + role for GitHub Actions deploys
- **Budgets** — $5/mo cost alert

## Backend

State lives in `s3://planetco-tfstate-862910165525` with S3 native locking
(via `use_lockfile = true`, no DynamoDB needed) in `eu-central-1`, account `862910165525`.

## Usage

```bash
# One-time SSO login
aws sso login --sso-session randolph

cd infrastructure
terraform init
terraform plan
terraform apply
```

Profile `planetco-website` is hardcoded in `providers.tf`.

## Outputs

```bash
terraform output cloudfront_domain         # current CloudFront URL
terraform output route53_nameservers       # NS to set at IONOS
terraform output github_actions_role_arn   # used by .github/workflows/deploy.yml
```
