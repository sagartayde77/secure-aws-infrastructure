# KMS Key for Project
resource "aws_kms_key" "project_kms" {
  description             = "KMS key for Secure AWS Infrastructure project"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "secure-aws-infra-kms"
    Project     = "secure-aws-infrastructure"
    Environment = "dev"
  }
}

# KMS Alias

resource "aws_kms_alias" "project_kms_alias" {
  name          = "alias/secure-aws-infra-kms"
  target_key_id = aws_kms_key.project_kms.key_id
}
