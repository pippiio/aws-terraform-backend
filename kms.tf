resource "aws_kms_key" "this" {
  for_each = var.backends

  description             = format("KMS CMK used for terraform backend '%s'", each.key)
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = merge(local.metadata.tags, {
    "Name" = format("alias/%s-%s-backend", each.key, each.value)
  })
}

resource "aws_kms_alias" "this" {
  for_each = var.backends

  name          = format("alias/%s%s-backend", local.metadata.name_prefix, each.key)
  target_key_id = aws_kms_key.this[each.key].key_id
}

resource "aws_kms_key_policy" "this" {
  for_each = var.backends

  key_id = aws_kms_key.this[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Key administrators"
        Effect = "Allow"
        Principal = {
          AWS = [local.metadata.iam_administrator_arn]
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid       = "Allow SSO decrypt usage"
        Effect    = "Allow"
        Principal = { AWS = local.read_access }
        Action = [
          "kms:DescribeKey",
          "kms:Decrypt",
        ]
        Resource = "*"
      },
      {
        Sid       = "Allow SSO encrypt usage"
        Effect    = "Allow"
        Principal = { AWS = local.write_access }
        Action = [
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:DescribeKey",
          "kms:Decrypt",
        ],
        Resource = "*"
      }
    ]
  })
}
