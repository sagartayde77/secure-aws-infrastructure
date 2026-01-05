# Security Group for VPN EC2 (Public)
resource "aws_security_group" "vpn_sg" {
  name        = "${var.project_name}-vpn-sg"
  description = "Security group for VPN EC2 (public)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH access from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr] #restricted to local system
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-vpn-sg"
  }
}

#Security Group for App EC2 (Private)
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for private EC2 (app)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH only from VPN EC2"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}
