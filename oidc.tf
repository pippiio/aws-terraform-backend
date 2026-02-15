locals {
  enable_github_oidc = length(var.github_repositories) > 0 ? 1 : 0
}

data "aws_iam_openid_connect_provider" "this" {
  count = local.enable_github_oidc

  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "oidc" {
  count = local.enable_github_oidc

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]

    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = [for tfstate in var.tfstate : "${aws_s3_bucket.this.arn}/${tfstate}"]
    }
  }

  dynamic "statement" {
    for_each = var.tfstate

    content {
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject"]
      resources = ["${aws_s3_bucket.this.arn}/${each.key}"]
    }
  }

  dynamic "statement" {
    for_each = var.tfstate

    content {
      effect    = "Allow"
      actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
      resources = ["${aws_s3_bucket.this.arn}/${each.key}.tflock"]
    }
  }
}

resource "aws_iam_role" "oidc" {
  count = local.enable_github_oidc

  name = "${var.name_prefix}${var.name}-github-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.this[0].arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [for repo in var.github_repositories : format("repo:%s:*", repo)]
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "oidc" {
  count = local.enable_github_oidc

  name   = "github-oidc"
  role   = aws_iam_role.oidc[count.index].id
  policy = data.aws_iam_policy_document.oidc[count.index].json
}
