########################################
# Security Group – Public VPN / Bastion EC2
########################################
resource "aws_security_group" "public" {
  name        = "${var.project_name}-public-vpn-sg"
  description = "Security group for WireGuard VPN / Bastion EC2"
  vpc_id      = aws_vpc.main.id

  ####################################
  # WireGuard VPN (UDP)
  ####################################
  ingress {
    description = "WireGuard VPN access"
    from_port   = var.wireguard_port
    to_port     = var.wireguard_port
    protocol    = "udp"
    cidr_blocks = var.vpn_allowed_cidrs
  }

  ####################################
  # Outbound traffic
  ####################################
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-public-vpn-sg"
    Environment = "public"
    Project     = var.project_name
  }
}

########################################
# Security Group – Private Application EC2
########################################
resource "aws_security_group" "private" {
  name        = "${var.project_name}-private-app-sg"
  description = "Security group for private application EC2"
  vpc_id      = aws_vpc.main.id

  ####################################
  # Allow traffic ONLY from WireGuard VPN
  ####################################
  ingress {
    description = "Allow traffic from WireGuard VPN clients"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.8.0.0/24"]
  }

  ####################################
  # (Optional) Allow SSM only (443)
  ####################################
  ingress {
    description = "Allow SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ####################################
  # Outbound traffic (via NAT)
  ####################################
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-private-app-sg"
    Environment = "private"
    Project     = var.project_name
  }
}
