resource "aws_s3_bucket" "s3_bucket" {
  count         = var.create_bucket ? 1 : 0
  bucket        = "${var.name_prefix}-${var.s3_bucket_name}-${var.name_postfix}"
  force_destroy = false

}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle" {
  bucket = aws_s3_bucket.s3_bucket[0].id
  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
   }
    filter {}
    id = "log"
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption_configuration" {
  count = var.create_bucket ? 1: 0
  bucket = aws_s3_bucket.s3_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public" {
  bucket = aws_s3_bucket.s3_bucket[0].id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true

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
      bucket = aws_s3_bucket.s3_bucket[0].id
      versioning_configuration {
        status = "Enabled"
      }
    }


resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket_logging.s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_logging" "s3_bucket_log" {
  bucket = "${var.name_prefix}-my-s3-access-logs-${var.name_postfix}"
  target_bucket = aws_s3_bucket.s3_bucket[0].id
  target_prefix = "log/"

}

resource "aws_sns_topic" "s3_bucket_notifications" {
  name = "bucket-notifications"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = aws_s3_bucket.s3_bucket[0].id

  topic {
    topic_arn     = aws_sns_topic.s3_bucket_notifications.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "logs/"
  }
}