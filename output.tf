output "backend" {
  description = "A map of backends with example usage"
  value = { for backend in var.backends : backend => <<-EOL
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.this[each.key].bucket}"
        key            = "${backend}.tfstate"
        region         = "${local.metadata.region}"
        encrypt        = true
        dynamodb_table = "${aws_dynamodb_table.this[tfstate].name}"
        allowed_account_ids = ["${local.metadata.account}"]

        # Use the below to have GitHub actions assume an IAM role using OIDC
        assume_role_with_web_identity = {
          role_arn                = var.backend_iam_role
          session_name            = "github-actions-session"
          web_identity_token_file = "/tmp/web_identity_token_file"
        }

        # Local apply only - DO NOT commit to git
        # profile = ""
      }
    }
  EOL
  }
}
