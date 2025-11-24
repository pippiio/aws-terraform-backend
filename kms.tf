resource "aws_kms_key" "this" {
  description = "KMS CMK used for ${var.name_prefix}${each.key} terraform state"

  for_each = var.config

  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = merge(local.default_tags, {
    "Name" = "${var.name_prefix}${each.key}-tfstate"
  })
}

# data "aws_iam_policy_document" "kms" {
#   statement {
#     resources = ["*"]
#     actions   = ["kms:*"]

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
#     }
#   }
# }

resource "aws_kms_alias" "this" {
  for_each = var.config

  name          = "alias/${var.name_prefix}${each.key}-tfstate"
  target_key_id = aws_kms_key.this[each.key].key_id
}
