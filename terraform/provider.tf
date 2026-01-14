##########################################################
# AWS Provider
##########################################################

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

##########################################################
# Current AWS Account (for KMS & audits)
##########################################################

data "aws_caller_identity" "current" {}
