########################################
# Global / Provider
########################################

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, test, prod)"
  type        = string
}

########################################
# Networking
########################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

########################################
# EC2
########################################

variable "instance_type" {
  description = "EC2 instance type for public VPN and private app EC2"
  type        = string
  default     = "t3.micro"
}

########################################
# WireGuard VPN
########################################

variable "wireguard_port" {
  description = "UDP port for WireGuard VPN"
  type        = number
  default     = 51820
}

variable "vpn_allowed_cidrs" {
  description = "CIDR blocks allowed to access WireGuard VPN"
  type        = list(string)
}

########################################
# S3
########################################

variable "s3_bucket_name" {
  description = "Globally unique S3 bucket name for application data"
  type        = string
}
