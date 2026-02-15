output "backend" {
  description = "Example backend manifest for tfstate"
  value = { for tfstate in var.tfstate : tfstate => <<-EOL
    terraform {
      backend "s3" {
        bucket              = "${aws_s3_bucket.this.bucket}"
        key                 = "${tfstate}.tfstate"
        region              = "${local.region_name}"
        encrypt             = true
        use_lockfile        = true
        allowed_account_ids = ["${local.account_id}"]
      }
    }
  EOL
  }
}

output "github_assume_rold_arn" {
  description = "IAM roled to be assumed by GitHub actions using OIDC"
  value       = try(aws_iam_role.oidc[0].arn, null)
}
