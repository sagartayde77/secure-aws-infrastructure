# Random suffix for global uniqueness
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Private S3 Bucket
resource "aws_s3_bucket" "secure_bucket" {
  bucket        = "secure-aws-infra-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name    = "secure-aws-infra-bucket"
    Project = "secure-aws-infrastructure"
  }
}

# Block ALL public access
resource "aws_s3_bucket_public_access_block" "secure_bucket_block" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Default encryption using KMS CMK

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.project_kms.arn
    }
  }
}

# Bucket policy: allow EC2 role only

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowEC2RoleAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ec2_role.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.secure_bucket.arn,
      "${aws_s3_bucket.secure_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.secure_bucket.arn,
      "${aws_s3_bucket.secure_bucket.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "secure_bucket_policy" {
  bucket = aws_s3_bucket.secure_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

