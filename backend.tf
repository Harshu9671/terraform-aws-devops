# --- S3 Remote Backend Configuration ---
#
# IMPORTANT: Before using this backend, you must create the S3 bucket manually:
#
#   aws s3api create-bucket \
#     --bucket <your-unique-bucket-name> \
#     --region us-east-1
#
#   aws s3api put-bucket-versioning \
#     --bucket <your-unique-bucket-name> \
#     --versioning-configuration Status=Enabled
#
# Then update the "bucket" value below with your actual bucket name.
#
# For first-time setup, comment out this block, run `terraform init` and
# `terraform apply` to create your infrastructure, then uncomment and run
# `terraform init` again to migrate state to S3.
#
# OIDC UPGRADE PATH (optional, stronger security):
# Instead of using long-lived AWS access keys, configure OpenID Connect (OIDC)
# between GitHub Actions and AWS IAM. This eliminates the need to store
# AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY as GitHub secrets.
# See: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

terraform {
  backend "s3" {
    bucket  = "your-terraform-state-bucket-name"
    key     = "terraform-aws-devops/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
