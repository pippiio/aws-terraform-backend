resource "time_static" "creation_time" {
  for_each = var.backends
}

resource "aws_s3_bucket" "this" {
  for_each = var.backends

  bucket = format("%s-%s-%s", local.metadata.name_prefix, each.key, formatdate("YYMMDDhh", time_static.creation_time[each.key].id))

  lifecycle {
    prevent_destroy = true
  }

  tags = local.metadata.tags
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = var.backends

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = var.backends

  bucket                  = aws_s3_bucket.this[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = var.backends

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this[each.key].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  for_each = var.backends

  bucket = aws_s3_bucket.this[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BackendPolicy"
    Statement = [
      {
        Sid       = "DenyObjectsThatAreNotSSEKMS",
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:PutObject"]
        Resource  = ["${aws_s3_bucket.this[each.key].arn}/*"]
        Condition = {
          ArnNotEqualsIfExists = { "s3:x-amz-server-side-encryption-aws-kms-key-id" : aws_kms_key.this[each.key].arn }
        }
      },
      {
        Sid       = "EnforceSSLRequests"
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:*"]
        Resource = [
          aws_s3_bucket.this[each.key].arn,
          "${aws_s3_bucket.this[each.key].arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Sid       = "ListBackendBucket"
        Effect    = "Allow"
        Principal = setunion(local.read_access, local.write_access)
        Action    = ["s3:ListBucket"]
        Resource  = [aws_s3_bucket.this[each.key].arn]
      },
      {
        Sid       = "ReadStateFile"
        Effect    = "Allow"
        Principal = setunion(local.read_access, local.write_access)
        Action    = ["s3:GetObject"]
        Resource  = format("%s/%s.tfstate", aws_s3_bucket.this[each.key].arn, each.key)
      },
      {
        Sid       = "ReadWriteStateFile"
        Effect    = "Allow"
        Principal = local.write_access
        Action    = ["s3:PutObject"]
        Resource  = format("%s/%s.tfstate", aws_s3_bucket.this[each.key].arn, each.key)
      },
    ]
  })
}
