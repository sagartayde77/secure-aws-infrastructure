########################################
# S3 Bucket – Private Application Data
########################################
resource "aws_s3_bucket" "app" {
  bucket = "${var.project_name}-${var.environment}-${random_id.suffix.hex}"
  force_destroy = true #for temperery destroy

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

########################################
# Enforce Bucket Ownership
########################################
resource "aws_s3_bucket_ownership_controls" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

########################################
# Block ALL Public Access
########################################
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################################
# Server-Side Encryption (KMS)
########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }

  depends_on = [aws_kms_key.main]
}
