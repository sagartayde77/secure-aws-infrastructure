##########################################################
# Public Subnet NACL – VPN / Bastion
##########################################################
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  tags = {
    Name        = "${var.project_name}-public-nacl"
    Environment = "public"
    Project     = var.project_name
  }

  ##########################################################
  # Inbound Rules
  ##########################################################

  # WireGuard VPN (UDP)
  ingress {
    rule_no    = 100
    protocol   = "udp"
    from_port  = var.wireguard_port
    to_port    = var.wireguard_port
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Ephemeral UDP ports (VPN return traffic)
  ingress {
    rule_no    = 110
    protocol   = "udp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Ephemeral TCP ports (SSM / updates)
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  ##########################################################
  # Outbound Rules
  ##########################################################
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }
}

##########################################################
# Private Subnet NACL – Application (SSM compatible)
##########################################################
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name        = "${var.project_name}-private-nacl"
    Environment = "private"
    Project     = var.project_name
  }

  ############################
  # Inbound Rules
  ############################

  # Allow return traffic from NAT / AWS services (SSM)
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }

  # Allow internal VPC traffic
  ingress {
    rule_no    = 110
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = var.vpc_cidr
    action     = "allow"
  }

  ############################
  # Outbound Rules
  ############################

  # Allow outbound internet (SSM → NAT → AWS)
  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
    action     = "allow"
  }
}
