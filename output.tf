output "backend" {
  value = { for tfstate in var.tfstate : tfstate => <<-EOL
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.this.bucket}"
        key            = "${tfstate}.tfstate"
        region         = "${local.region_name}"
        encrypt        = true
        allowed_account_ids = ["${local.account_id}"]
        kms_key_id     = "${aws_kms_key.this.arn}"
        use_lockfile        = true

        # assume_role = {
        #   role_arn     = "arn:aws:iam::${local.account_id}:role/OrganizationAccountAccessRole"
        #   session_name = "Terraform"
        # }

        # Local apply only - DO NOT commit to git
        # access_key          = ""
        # secret_key          = ""
        # token               = ""
      }
    }
  EOL
  }
}
