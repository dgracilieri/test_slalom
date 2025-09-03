resource "aws_s3_bucket" "s3_bucket" {
  count  = var.create_bucket ? 1: 0
  bucket = "${var.name_prefix}-${var.s3_bucket_name}-${var.name_postfix}"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "call_record_bucket_encryption_configuration" {
  count = var.create_bucket ? 1: 0
  bucket = aws_s3_bucket.s3_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 bucket encryption"
  is_enabled = true
  enable_key_rotation = true
  deletion_window_in_days = 10
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 to use the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::*"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
      bucket = aws_s3_bucket.s3_bucket.id
      versioning_configuration {
        status = "Enabled"
      }
    }

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "s3_bucket_log" {
  bucket = "${var.name_prefix}-my-s3-access-logs-${var.name_postfix}"
  target_bucket = aws_s3_bucket.s3_bucket.id
  target_prefix = "log/"
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "call_record_bucket_encryption_configuration" {
  count = var.create_bucket ? 1: 0
  bucket = aws_s3_bucket.log_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}