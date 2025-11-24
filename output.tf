output "backend" {
  value = { for k, v in var.config : k => <<-EOL
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.this[k].bucket}"
        key            = "${v.name}.tfstate"
        region         = "${local.region_name}"
        encrypt        = true
        kms_key_id     = "${aws_kms_alias.this[k].name}"
        use_lockfile        = true

        assume_role_with_web_identity = {
          role_arn     = "${aws_iam_role.this[k].arn}"
          session_name = "Terraform"
        }

        # Local apply only - DO NOT commit to git
        # access_key          = ""
        # secret_key          = ""
        # token               = ""
      }
    }
  EOL
  }
}
