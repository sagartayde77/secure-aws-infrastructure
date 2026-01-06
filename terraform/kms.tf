# Get current AWS account ID

data "aws_caller_identity" "current" {}

# KMS Key Policy

data "aws_iam_policy_document" "kms_key_policy" {

  # Allow root account full control (MANDATORY)
  statement {
    sid    = "AllowRootAccount"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  # Allow EC2 IAM role to use the key
  statement {
    sid    = "AllowEC2RoleUsage"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ec2_role.arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]
  }
}

# KMS Key

resource "aws_kms_key" "project_kms" {
  description             = "KMS key for Secure AWS Infrastructure project"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key_policy.json

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
