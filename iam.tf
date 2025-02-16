locals {
  read_access = setunion(
    [for backend, role in aws_iam_role.github_readonly : role.arn],
    toset(flatten([
      for backend in values(var.backends) : [
        for iam_role in backend.access.iam_role : data.aws_iam_role.iam_role[iam_role.role_arn].arn
        if iam_role.write == false
    ]])),
  )

  write_access = setunion(
    [for backend, role in aws_iam_role.github_readwrite : role.arn],
    toset(flatten([
      for backend in values(var.backends) : [
        for iam_role in backend.access.iam_role : data.aws_iam_role.iam_role[iam_role.role_arn].arn
    ]])),
  )
}

data "aws_iam_role" "iam_role" {
  for_each = toset(flatten([
    for backend in values(var.backends) : [
      for iam_role in backend.access.iam_role : iam_role.role_arn
  ]]))

  name = each.key
}

data "aws_iam_openid_connect_provider" "github" {
  count = try(length(var.backends.access.github), -1) > 0 ? 1 : 0

  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_readwrite" {
  for_each = { for backend, sub in {
    for backend_name, backend in var.backends : backend_name => [
      for github in backend.access.github :
      format("repo:%s/%s:%s", github.organization, github.repository, github.branch)
      if github.write
  ] } : backend => sub if length(sub) > 0 }

  name = format("%s-%s-backend-github-write", local.metadata.name_prefix, each.key)
  tags = local.metadata.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github[0].arn }
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"] }
        StringLike   = { "token.actions.githubusercontent.com:sub" = each.value }
      }
    }]
  })
}

resource "aws_iam_role" "github_readonly" {
  for_each = { for backend, sub in {
    for backend_name, backend in var.backends : backend_name => [
      for github in backend.access.github :
      format("repo:%s/%s:%s", github.organization, github.repository, github.branch)
      if github.write == false
  ] } : backend => sub if length(sub) > 0 }

  name = format("%s-%s-backend-github-readonly", local.metadata.name_prefix, each.key)
  tags = local.metadata.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github[0].arn }
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = ["sts.amazonaws.com"] }
        StringLike   = { "token.actions.githubusercontent.com:sub" = each.value }
      }
    }]
  })
}
