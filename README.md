# 🔐 Secure AWS Infrastructure using Terraform

This project provisions a **secure, production-style AWS infrastructure** using **Terraform**, designed to host an **internal company application** that must **not be publicly accessible**.

Access to the private application is available **only through a WireGuard VPN** and **AWS Systems Manager (SSM)**.

## 🧠 Project Objective

The primary goals of this project are:

- Build a secure AWS environment
- Prevent direct public access to internal applications
- Enforce least-privilege IAM
- Enable encryption at rest
- Maintain low operational cost
- Automate infrastructure provisioning using Terraform

## 🏗️ Architecture Overview

Client Laptop
|
| WireGuard VPN
v
Public EC2 (VPN / Bastion)
|
v
Private EC2 (Internal Application)
|
v
NAT Gateway → Internet (updates, yum, curl)

Private S3 Bucket (KMS Encrypted)

## ✅ Infrastructure Components

### Networking
- 1 VPC
- 2 Subnets (Public & Private)
- Internet Gateway (IGW)
- NAT Gateway
- Elastic IP
- Public Route Table
- Private Route Table
- Public & Private Network ACLs

### Compute
- Public EC2 (WireGuard VPN Server)
- Private EC2 (Internal Application Server)
- No public IP on private EC2

### Security
- Security Groups
- Network ACLs (stateless traffic control)
- AWS Systems Manager (SSM)
- Least-privilege IAM roles
- AWS KMS encryption for:
  - EC2 root volumes
  - S3 bucket

### Storage
- Private S3 bucket
- Public access fully blocked
- KMS encryption enabled
- Versioning disabled (cost optimization)
- `force_destroy = true` enabled for clean teardown

## 🔐 Security Design

- ❌ No SSH access
- ❌ No public-facing application
- ✅ VPN-only internal access
- ✅ SSM access without public IP
- ✅ Strict least-privilege IAM policies

## 💰 Cost Optimization Strategy

- Single NAT Gateway
- No unnecessary AWS services
- S3 versioning disabled
- Small EC2 instance types
- Clean Terraform destroy supported

> ⚠️ NAT Gateway is the primary cost contributor.

## 📁 Project Structure

secure-aws-infra/
│
├── diagrams/
│ └── architecture.png
│
├── terraform/
│ ├── .terraform/
│ ├── .terraform.lock.hcl
│ │
│ ├── ec2.tf
│ ├── iam.tf
│ ├── kms.tf
│ ├── main.tf
│ ├── nacl.tf
│ ├── outputs.tf
│ ├── provider.tf
│ ├── random.tf
│ ├── s3.tf
│ ├── security.tf
│ ├── variables.tf
│ ├── versions.tf
│ ├── vpc_endpoints.tf
│ │
│ ├── terraform.tfvars.example
│ └── terraform.tfstate*
│
├── .gitignore
└── README.md

## 🚀 Deployment Steps

### 1. Clone the repository

git clone https://github.com/sagartayde77/secure-aws-infra.git
cd secure-aws-infra/terraform
2. Configure variables
cp terraform.tfvars.example terraform.tfvars
Update values as required.

3. Initialize Terraform
terraform init
4. Apply infrastructure
terraform apply
Type:

yes
🧪 Testing Checklist
VPN Connectivity
Connect using WireGuard client

Client receives IP 10.8.0.2

Internal Application Access

curl http://<private-ec2-private-ip>
Expected output:

hello from private ec2
Private EC2 Internet Access
curl https://google.com
SSM Access
Private EC2 reachable via Session Manager

No public IP required

S3 Access (from private EC2)

aws s3 ls s3://<bucket-name>
aws s3 cp test.txt s3://<bucket-name>/
🧨 Destroy Infrastructure
terraform destroy
All resources are removed safely.

🧠 Key Learnings
Secure VPC architecture design

NAT Gateway routing behavior

Network ACL vs Security Group differences

VPN-based private access model

SSM access without public IP

KMS encryption implementation

Least-privilege IAM design

Terraform automation and dependency handling

👨‍💻 Author
Sagar Tayde
Cloud & DevOps Enthusiast
India 🇮🇳