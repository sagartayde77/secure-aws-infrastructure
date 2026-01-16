########################################
# Outputs
########################################

output "vpn_public_ip" {
  description = "Public IP of WireGuard VPN EC2"
  value       = aws_instance.public_vpn.public_ip
}

output "vpn_instance_id" {
  description = "Instance ID of VPN EC2"
  value       = aws_instance.public_vpn.id
}

output "private_instance_id" {
  description = "Instance ID of Private App EC2"
  value       = aws_instance.private_app.id
}

output "s3_bucket_name" {
  description = "Private application S3 bucket"
  value       = aws_s3_bucket.app.bucket
}

output "kms_key_arn" {
  description = "KMS key ARN used for encryption"
  value       = aws_kms_key.main.arn
}
