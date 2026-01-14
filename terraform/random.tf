########################################
# Random suffix for S3 bucket uniqueness
########################################
resource "random_string" "s3_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}
