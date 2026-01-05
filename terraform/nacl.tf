# Public Subnet NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.public.id
  ]

  tags = {
    Name    = "public-nacl"
    Project = "secure-aws-infrastructure"
  }
}

# Inbound: Allow SSH & HTTP/HTTPS (from anywhere)
resource "aws_network_acl_rule" "public_in_ssh" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
  egress         = false
}

resource "aws_network_acl_rule" "public_in_http_https" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 443
  egress         = false
}

# Outbound: Allow all
resource "aws_network_acl_rule" "public_out_all" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

# Public Inbound ephemeral rule
resource "aws_network_acl_rule" "public_in_ephemeral" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  egress         = false
}

#####################################################################

# Private Subnet NACL
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id

  subnet_ids = [
    aws_subnet.private.id
  ]

  tags = {
    Name    = "private-nacl"
    Project = "secure-aws-infrastructure"
  }
}

# Inbound: Allow SSH from public subnet only
resource "aws_network_acl_rule" "private_in_ssh" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.public.cidr_block
  from_port      = 22
  to_port        = 22
  egress         = false
}

# Outbound: Allow all (for NAT / updates)
resource "aws_network_acl_rule" "private_out_all" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

# Private Inbound ephemeral rule
resource "aws_network_acl_rule" "private_in_ephemeral" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  egress         = false
}
