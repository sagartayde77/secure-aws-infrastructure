########################################
# Project
########################################
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

########################################
# AWS
########################################
variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

########################################
# Networking
########################################
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

########################################
# EC2
########################################
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

########################################
# VPN / WireGuard
########################################
variable "wireguard_port" {
  type    = number
  default = 51820
}

variable "vpn_allowed_cidrs" {
  type = list(string)
}

variable "vpn_subnet_cidr" {
  type    = string
  default = "10.8.0.0/24"
}

########################################
# Application
########################################
variable "app_port" {
  type    = number
  default = 80
}

########################################
# WireGuard / VPN
########################################

variable "vpn_server_ip" {
  type        = string
  description = "WireGuard server IP with CIDR"
  default     = "10.8.0.1/24"
}

variable "vpn_client_ip" {
  type        = string
  description = "WireGuard client IP with CIDR"
  default     = "10.8.0.2/32"
}