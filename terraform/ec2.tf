# VPN / Bastion EC2 (Public)

resource "aws_instance" "vpn_ec2" {
  ami                         = var.amazon_linux_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.vpn_sg.id]
  associate_public_ip_address = true

  # SSH key pair
  key_name = "secure-aws-infra-key"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = aws_kms_key.project_kms.arn
  }

  tags = {
    Name        = "secure-aws-infra-vpn-ec2"
    Project     = "secure-aws-infrastructure"
    Environment = "dev"
  }
}


# Private App EC2

resource "aws_instance" "private_ec2" {
  ami                         = var.amazon_linux_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = false

  # SSH key pair
  key_name = "secure-aws-infra-key"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = aws_kms_key.project_kms.arn
  }

  tags = {
    Name        = "secure-aws-infra-private-ec2"
    Project     = "secure-aws-infrastructure"
    Environment = "dev"
  }
}
