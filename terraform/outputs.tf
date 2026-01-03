output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "kms_key_id" {
  value = aws_kms_key.project_kms.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.project_kms.arn
}
