# Project IAM User
resource "aws_iam_user" "project_user" {
  name = "${var.project_name}-user"
}

# IAM Role for the Project
data "aws_iam_policy_document" "project_role_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.project_user.arn]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create the Role
resource "aws_iam_role" "project_role" {
  name               = "${var.project_name}-role"
  assume_role_policy = data.aws_iam_policy_document.project_role_trust.json
}

# Permissions to the role (AWS Managed)
resource "aws_iam_role_policy_attachment" "ec2_full" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "kms_full" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_role_policy_attachment" "vpc_readonly" {
  role       = aws_iam_role.project_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCReadOnlyAccess"
}

# EC2 Instance Role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create EC2 role
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

# Attach S3+KMS permissions
resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_kms" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

