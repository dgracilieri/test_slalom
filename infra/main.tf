resource "aws_s3_bucket" "s3_bucket" {
  count  = var.create_bucket ? 1: 0
  bucket = "${var.name_prefix}-${var.s3_bucket_name}-${var.name_postfix}"
  force_destroy = false
}
resource "aws_s3_bucket_server_side_encryption_configuration" "call_record_bucket_encryption_configuration" {
  count = var.create_bucket ? 1: 0
  bucket = aws_s3_bucket.s3_bucket[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
