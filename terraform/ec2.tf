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

############################
# SSM Agent (AL2023)
############################
dnf install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

############################
# WireGuard variables
############################
WG_INTERFACE="wg0"
WG_DIR="/etc/wireguard"
CLIENT_DIR="/root/wireguard-clients"
WG_PORT=51820
WG_SUBNET="10.8.0.0/24"
WG_SERVER_IP="10.8.0.1/24"
CLIENT_IP="10.8.0.2/32"

############################
# Install WireGuard
############################
dnf install -y wireguard-tools iptables-services

############################
# Enable IP forwarding
############################
cat <<SYSCTL >/etc/sysctl.d/99-wireguard.conf
net.ipv4.ip_forward = 1
SYSCTL
sysctl --system

############################
# Detect primary interface
############################
PRIMARY_IF=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

############################
# Prepare directories
############################
mkdir -p $WG_DIR
mkdir -p $CLIENT_DIR
chmod 700 $WG_DIR
chmod 700 $CLIENT_DIR

############################
# Generate SERVER keys
############################
cd $WG_DIR
wg genkey | tee server_private.key | wg pubkey > server_public.key
chmod 600 server_private.key

SERVER_PRIVATE_KEY=$(cat server_private.key)
SERVER_PUBLIC_KEY=$(cat server_public.key)

############################
# Generate CLIENT keys
############################
cd $CLIENT_DIR
wg genkey | tee client1_private.key | wg pubkey > client1_public.key
chmod 600 client1_private.key

CLIENT_PRIVATE_KEY=$(cat client1_private.key)
CLIENT_PUBLIC_KEY=$(cat client1_public.key)

############################
# Create wg0.conf (SERVER)
############################
cat <<WGCONF >$WG_DIR/$WG_INTERFACE.conf
[Interface]
Address = $WG_SERVER_IP
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIVATE_KEY

PostUp   = iptables -t nat -A POSTROUTING -s $WG_SUBNET -o $PRIMARY_IF -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s $WG_SUBNET -o $PRIMARY_IF -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP
WGCONF

chmod 600 $WG_DIR/$WG_INTERFACE.conf

############################
# Create client1.conf
############################

# Fetch IMDSv2 token
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch public IPv4 using token
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)


cat <<CLIENTCONF >$CLIENT_DIR/client1.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.8.0.2/32
DNS = 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $PUBLIC_IP:$WG_PORT
AllowedIPs = 10.0.0.0/16
PersistentKeepalive = 25
CLIENTCONF

chmod 600 $CLIENT_DIR/client1.conf

############################
# Start WireGuard
############################
systemctl enable wg-quick@$WG_INTERFACE
systemctl restart wg-quick@$WG_INTERFACE

echo "=== WireGuard setup completed ==="
echo "Client config located at: /root/wireguard-clients/client1.conf"
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
