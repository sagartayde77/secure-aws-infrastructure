########################################
# KMS Key (EBS + S3 Encryption)
########################################
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} (EBS and S3 encryption)"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      ####################################
      # Allow root account full access
      ####################################
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      ####################################
      # Allow EC2 roles to use the key
      ####################################
      {
        Sid    = "AllowEC2UseOfKey"
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.public_ssm.arn,
            aws_iam_role.private_ec2.arn
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-kms-key"
    Project = var.project_name
  }
}

########################################
# KMS Alias
########################################
resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-kms"
  target_key_id = aws_kms_key.main.key_id
}
