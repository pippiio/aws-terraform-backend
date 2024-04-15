resource "aws_kms_key" "this" {
  description             = "KMS CMK used for ${var.name_prefix}${var.name} terraform state"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = merge(local.default_tags, {
    "Name" = "${var.name_prefix}${var.name}-tfstate"
  })
}

data "aws_iam_policy_document" "kms" {
  statement {
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name_prefix}${var.name}-tfstate"
  target_key_id = aws_kms_key.this.key_id
}
