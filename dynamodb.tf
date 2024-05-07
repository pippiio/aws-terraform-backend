resource "aws_dynamodb_table" "this" {
  for_each = length(var.tfstate) > 0 ? var.tfstate : toset([var.name])

  name         = "${local.name_prefix}${var.name}-${each.key}-tfstate"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.this.arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.default_tags
}
