<!-- BEGIN_TF_DOCS -->
# aws-terraform-backend
The _aws-terraform-backend_ is a generic [Terraform](https://www.terraform.io/) module within the [pippi.io](https://pippi.io) family, maintained by [Tech Chapter](https://techchapter.com/). The pippi.io modules are build to support common use cases often seen at Tech Chapters clients. They are created with best practices in mind and battle tested at scale. All modules are free and open-source under the Apache License 2.0.

The aws-terraform-backend module is made to provision and manage a Terraform and OpenTofu AWS S3 backends.

# Examples

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~>1.7 |
| aws | ~>6 |

## Providers

| Name | Version |
|------|---------|
| aws | ~>6 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of tfstate bucket | `string` | n/a | yes |
| default\_tags | A map of default tags, that will be applied to all resources applicable. | `map(string)` | `{}` | no |
| github\_repositories | A set of GitHub repositories with OIDC read/wrtie access to tfstate | `set(string)` | `[]` | no |
| name\_prefix | A prefix that will be used on all named resources. | `string` | `"pippi-"` | no |
| tfstate | A list of tfstates to create within bucket | `set(string)` | `[]` | no |



## Resources

| Name | Type |
|------|------|
| [aws_iam_role.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Outputs

| Name | Description |
|------|-------------|
| backend | Example backend manifest for tfstate |
| github\_assume\_rold\_arn | IAM roled to be assumed by GitHub actions using OIDC |

<!-- END_TF_DOCS -->