# --- Variable Values ---
# Override default values here. Do NOT put secrets in this file.
# AWS credentials should be set via environment variables or GitHub Actions secrets.

aws_region         = "us-east-1"
project_name       = "terraform-aws-devops"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone  = "us-east-1a"
instance_type      = "t2.micro"
key_name           = ""
