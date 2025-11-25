locals {
  github_oidc_thumbprints = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  oidc_exists             = data.external.oidc_exists.result.exists == "true"
}

data "external" "oidc_exists" {
  program = ["bash", "${path.module}/check_oidc.sh", var.profile]
}

data "aws_iam_openid_connect_provider" "this" {
  count = local.oidc_exists ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "this" {
  count           = local.oidc_exists == false && length(var.github_repos) > 0 ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = local.github_oidc_thumbprints
}

resource "aws_iam_role" "this" {
  count = length(var.github_repos) > 0 ? 1 : 0
  name  = "${var.name_prefix}${var.name}-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = data.external.oidc_exists.result.exists ? data.aws_iam_openid_connect_provider.this[0].arn : aws_iam_openid_connect_provider.this[0].arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [for repo in var.github_repos : format("repo:%s:*", repo)]
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.github_repos) > 0 ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
