output "backend" {
  value = { for tfstate in var.tfstate : tfstate => <<-EOL
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.this.bucket}"
        key            = "${tfstate}.tfstate"
        region         = "${local.region_name}"
        encrypt        = true
        dynamodb_table = "${aws_dynamodb_table.this[tfstate].name}"
        allowed_account_ids = ["${local.account_id}"]

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
