resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

module "backend" {
    source = "git@github.com:pippiio/aws-terraform-backend.git?ref=v0.0.0"

  name = "pippi.io"

  tfstate = [
    "example"
  ]

  github_repositories = [
    "pippiio/aws-teraform-backend"
  ]

  depends_on = [aws_iam_openid_connect_provider.github]
}
