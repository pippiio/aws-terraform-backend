<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| terraform | ~>1.10 |
| aws | ~> 5 |
| time | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5 |
| time | ~> 0.12 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backends | A map of named backends:<br/>  administrator\_iam\_role: Gets KMS key admin rights. Defaults to metadata.iam\_administrator\_arn<br/>  access: Grants backend permissions<br/>    iam\_role: (Optional) Set of IAM roles w. backend permissions<br/>      name: The name of the IAM role <br/>      write: Wheter to grant the role write permissions (apply, import, etc.)<br/>    github: (Optional) Set of GitHub repositories, :<br/>      organization: GitHub organization name.<br/>      repository: GitHub repository subject to the access permission.<br/>      branch: Git branch subject to the access permissions. Defaults to all branches.<br/>      write: Wheter to grant the role write permissions (apply, import, etc.) | <pre>map(object({<br/>    administrator_iam_role = optional(string, null)<br/>    access = object({<br/>      iam_role = optional(set(object({<br/>        role_arn = string<br/>        write    = bool<br/>      })), [])<br/>      github = optional(set(object({<br/>        organization = string<br/>        repository   = string<br/>        branch       = optional(string, "*")<br/>        write        = bool<br/>      })), [])<br/>    })<br/>  }))</pre> | n/a | yes |
| metadata | JSON encoded metadata. | `string` | n/a | yes |



## Resources

| Name | Type |
|------|------|
| [aws_iam_role.github_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_readwrite](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [time_static.creation_time](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) | resource |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_role.iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Outputs

| Name | Description |
|------|-------------|
| backend | A map of backends with example usage |

<!-- END_TF_DOCS -->