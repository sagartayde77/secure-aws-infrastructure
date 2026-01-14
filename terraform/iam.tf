########################################
# IAM Role – Public EC2 (SSM ONLY)
########################################
resource "aws_iam_role" "public_ssm" {
  name = "${var.project_name}-public-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-public-ssm-role"
    Project = var.project_name
  }
}

########################################
# Attach AWS-managed SSM policy (Public)
########################################
resource "aws_iam_role_policy_attachment" "public_ssm" {
  role       = aws_iam_role.public_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

########################################
# Instance Profile – Public EC2
########################################
resource "aws_iam_instance_profile" "public_ssm" {
  name = "${var.project_name}-public-ssm-profile"
  role = aws_iam_role.public_ssm.name
}

########################################
# IAM Role – Private EC2 (S3 + optional SSM)
########################################
resource "aws_iam_role" "private_ec2" {
  name = "${var.project_name}-private-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-private-ec2-role"
    Project = var.project_name
  }
}

########################################
# (Optional but Recommended) SSM for Private EC2
########################################
resource "aws_iam_role_policy_attachment" "private_ssm" {
  role       = aws_iam_role.private_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

########################################
# Custom S3 Access Policy (Private EC2)
########################################
resource "aws_iam_policy" "private_s3_access" {
  name        = "${var.project_name}-private-s3-access"
  description = "Allow private EC2 to access encrypted S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app.arn,
          "${aws_s3_bucket.app.arn}/*"
        ]
      }
    ]
  })
}

########################################
# Attach S3 policy to Private EC2 role
########################################
resource "aws_iam_role_policy_attachment" "private_s3" {
  role       = aws_iam_role.private_ec2.name
  policy_arn = aws_iam_policy.private_s3_access.arn
}

########################################
# Instance Profile – Private EC2
########################################
resource "aws_iam_instance_profile" "private_ec2" {
  name = "${var.project_name}-private-ec2-profile"
  role = aws_iam_role.private_ec2.name
}
