resource "aws_iam_openid_connect_provider" "this" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints
}

resource "aws_iam_role" "this" {
  for_each = var.config
  name     = "${var.name_prefix}${each.key}-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"]
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [for repo in each.value.github : format("repo:%s:*", repo)]
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.config

  role       = aws_iam_role.this[each.key].name
  policy_arn = [for policy in each.value.policy : policy][0]
}
