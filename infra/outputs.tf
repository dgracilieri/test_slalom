output "s3_bucket_name" {
  description = "Bucket which contains all the call recordings"
  value       = aws_s3_bucket.s3_bucket[0].id
}