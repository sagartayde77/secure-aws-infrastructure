########################################
# Public Subnet NACL (FINAL)
########################################
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  ####################################
  # Inbound rules
  ####################################

  # WireGuard VPN
  ingress {
    rule_no    = 100
    protocol   = "udp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.wireguard_port
    to_port    = var.wireguard_port
  }

  # HTTP return traffic (NAT)
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # HTTPS return traffic (NAT)
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Ephemeral ports
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ####################################
  # Outbound rules
  ####################################
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project_name}-public-nacl"
  }
}

########################################
# Public NACL Association
########################################
resource "aws_network_acl_association" "public" {
  subnet_id      = aws_subnet.public.id
  network_acl_id = aws_network_acl.public.id
}

########################################
# Private Subnet NACL (SAFE TEMPLATE)
########################################
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  ####################################
  # Inbound rules
  ####################################

  # Allow internal VPC traffic (VPN, ALB, SSM endpoints)
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  # Allow return traffic from NAT / internet
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ####################################
  # Outbound rules
  ####################################

  # Allow all outbound traffic
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project_name}-private-nacl"
  }
}


########################################
# Private NACL Association
########################################
resource "aws_network_acl_association" "private" {
  subnet_id      = aws_subnet.private.id
  network_acl_id = aws_network_acl.private.id
}
