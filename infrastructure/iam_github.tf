resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub Actions OIDC thumbprint (AWS no longer enforces this for the
  # github.com IdP, but keeping it matches the auto-populated state).
  thumbprint_list = ["22ff89586561fc2d52f77491e9f1eff1b80be33e"]
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name               = "github-actions-planetco-deploy"
  description        = "Allows GitHub Actions from randolph-mb/planetco.ai to deploy to S3 + invalidate CloudFront"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "deploy-permissions"
  role = aws_iam_role.github_actions_deploy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3SyncWebsiteBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = aws_s3_bucket.website.arn
      },
      {
        Sid      = "S3ObjectsWebsiteBucket"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.website.arn}/*"
      },
      {
        Sid      = "CloudFrontInvalidation"
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation", "cloudfront:ListInvalidations"]
        Resource = aws_cloudfront_distribution.website.arn
      }
    ]
  })
}
