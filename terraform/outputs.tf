########################################
# Public VPN / Bastion EC2 Outputs
########################################

output "public_vpn_public_ip" {
  description = "Public IP address of the VPN / Bastion EC2 (used for initial access)"
  value       = aws_instance.public_vpn.public_ip
}

########################################
# Private Application EC2 Outputs
########################################

output "private_app_instance_id" {
  description = "Instance ID of the private application EC2"
  value       = aws_instance.private_app.id
}
