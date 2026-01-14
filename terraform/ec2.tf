########################################
# AMI: Amazon Linux 2023 (Latest)
########################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

########################################
# Public EC2 – VPN / Bastion Host
# SSM + WireGuard (Auto)
########################################
resource "aws_instance" "public_vpn" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true

  # Required for VPN routing
  source_dest_check = false

  # IAM for SSM
  iam_instance_profile = aws_iam_instance_profile.public_ssm.name

  ####################################
  # USER DATA (SSM + WireGuard)
  ####################################
  user_data = <<-EOF
    #!/bin/bash
    set -e

    echo "=== Cloud-init started ==="

    ####################################
    # Ensure SSM Agent (AL2023 safety)
    ####################################
    dnf install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    ####################################
    # WireGuard Setup
    ####################################
    WG_INTERFACE="wg0"
    WG_DIR="/etc/wireguard"
    WG_PORT=51820
    WG_SUBNET="10.8.0.0/24"
    WG_SERVER_IP="10.8.0.1/24"

    dnf install -y wireguard-tools iptables-services

    # Enable IP forwarding
    cat <<SYSCTL >/etc/sysctl.d/99-wireguard.conf
    net.ipv4.ip_forward = 1
    SYSCTL
    sysctl --system

    # Detect primary interface
    PRIMARY_IF=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

    # Prepare WireGuard directory
    mkdir -p $WG_DIR
    chmod 700 $WG_DIR
    cd $WG_DIR

    # Generate server keys (only once)
    if [ ! -f server_private.key ]; then
      wg genkey | tee server_private.key | wg pubkey > server_public.key
      chmod 600 server_private.key
    fi

    SERVER_PRIVATE_KEY=$(cat server_private.key)

    # Create wg0.conf
    cat <<WGCONF >$WG_DIR/$WG_INTERFACE.conf
    [Interface]
    Address = $WG_SERVER_IP
    ListenPort = $WG_PORT
    PrivateKey = $SERVER_PRIVATE_KEY

    PostUp   = iptables -t nat -A POSTROUTING -s $WG_SUBNET -o $PRIMARY_IF -j MASQUERADE
    PostDown = iptables -t nat -D POSTROUTING -s $WG_SUBNET -o $PRIMARY_IF -j MASQUERADE
    WGCONF

    chmod 600 $WG_DIR/$WG_INTERFACE.conf

    systemctl enable wg-quick@$WG_INTERFACE
    systemctl restart wg-quick@$WG_INTERFACE

    echo "=== Cloud-init finished successfully ==="
  EOF

  ####################################
  # Encrypted Root Volume
  ####################################
  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.main.arn
  }

  tags = {
    Name        = "${var.project_name}-public-vpn"
    Environment = "public"
    Project     = var.project_name
  }
}



########################################
# Private EC2 – Application Server
########################################
resource "aws_instance" "private_app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.private.id]
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.private_ec2.name

  user_data = <<-EOF
#!/bin/bash
dnf install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
EOF

  ####################################
  # Encrypted Root Volume (KMS)
  ####################################
  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.main.arn
  }

  tags = {
    Name        = "${var.project_name}-private-app"
    Environment = "private"
    Project     = var.project_name
  }
}
