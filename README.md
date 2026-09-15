# AWS Infrastructure Automation using Terraform, S3 Remote State & GitHub Actions

Automated AWS infrastructure provisioning using Terraform with modular configuration, S3 remote state management, and GitHub Actions CI/CD pipeline.

---

## Architecture

```
GitHub Repository
        |
        v
  GitHub Actions
        |
  Terraform Plan
        |
  Terraform Apply
        |
        v
+----------------------+
|       AWS VPC        |
|                      |
|   Public Subnet      |
|       |              |
|      EC2             |
|       |              |
|   Security Group     |
+----------------------+
        |
        v
  S3 Remote State
```

## Project Structure

```
terraform-aws-devops/
├── .github/
│   └── workflows/
│       └── terraform.yml      # CI/CD pipeline
├── modules/
│   ├── networking/            # VPC, Subnet, IGW, Route Table
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/                   # Security Group, AMI, EC2 Instance
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                    # Root module (wires modules together)
├── providers.tf               # AWS provider configuration
├── variables.tf               # Root input variables
├── outputs.tf                 # Root outputs
├── backend.tf                 # S3 remote state configuration
├── terraform.tfvars           # Variable values (no secrets!)
├── .gitignore
└── README.md
```

## Tech Stack

| Category        | Technology      |
|-----------------|-----------------|
| Cloud           | AWS             |
| IaC             | Terraform       |
| CI/CD           | GitHub Actions  |
| Version Control | Git / GitHub    |

## AWS Resources Created

- **VPC** — Custom VPC with DNS support
- **Public Subnet** — With auto-assign public IP
- **Internet Gateway** — For outbound internet access
- **Route Table** — Routes traffic to the Internet Gateway
- **Security Group** — Allows SSH (22) and HTTP (80) inbound
- **EC2 Instance** — Amazon Linux 2023, t2.micro (free-tier)
- **S3 Bucket** — Remote Terraform state storage (created manually)

---

## Prerequisites

1. **AWS Account** with programmatic access (Access Key ID & Secret)
2. **Terraform** >= 1.0 installed locally ([Install Guide](https://developer.hashicorp.com/terraform/install))
3. **AWS CLI** configured (optional, for S3 bucket creation)
4. **GitHub** repository with Actions enabled

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/terraform-aws-devops.git
cd terraform-aws-devops
```

### 2. Create the S3 State Bucket

```bash
# Create the bucket
aws s3api create-bucket \
  --bucket harshu-terraform-state-2026 \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket harshu-terraform-state-2026 \
  --versioning-configuration Status=Enabled
```

### 3. Update Backend Configuration

Edit `backend.tf` and ensure the bucket is set to `harshu-terraform-state-2026`.

### 4. Configure GitHub Secrets

In your GitHub repository, go to **Settings → Secrets and variables → Actions** and add:

| Secret Name            | Value                       |
|------------------------|-----------------------------|
| `AWS_ACCESS_KEY_ID`    | Your AWS access key         |
| `AWS_SECRET_ACCESS_KEY`| Your AWS secret access key  |

> ⚠️ **Security Note**: Never commit AWS credentials to your repository. Use GitHub Actions secrets or, for stronger security, configure [OIDC with AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

### 5. Deploy Locally (Optional)

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

### 6. Deploy via CI/CD

Simply push to `main` or open a pull request:

```bash
git add .
git commit -m "Initial Terraform infrastructure"
git push origin main
```

---

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform.yml`) runs automatically:

| Trigger          | Steps                                       |
|------------------|---------------------------------------------|
| **Pull Request** | Format Check → Init → Validate → Plan       |
| **Push to main** | Format Check → Init → Validate → Plan → Apply |

- Plan output is automatically posted as a **comment on PRs**
- Apply only executes on pushes to `main` (after PR merge)
- Format check uses `terraform fmt -check -recursive`

---

## Customization

Edit `terraform.tfvars` to customize your deployment:

```hcl
aws_region         = "us-east-1"
project_name       = "terraform-aws-devops"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
availability_zone  = "us-east-1a"
instance_type      = "t2.micro"
key_name           = ""  # Set to your EC2 key pair name for SSH access
```

## Cleanup

To destroy all resources and avoid ongoing charges:

```bash
terraform destroy
```

Or update the GitHub Actions workflow to run `terraform destroy` on a specific trigger.

---

## Resume Bullet Points

> - Automated AWS infrastructure provisioning using Terraform, including VPC, public subnet, Internet Gateway, route tables, security groups, and EC2.
> - Configured an S3 remote backend for centralized Terraform state management and version-controlled Infrastructure as Code using GitHub.
> - Implemented GitHub Actions CI/CD to automatically format, validate, plan, and deploy Terraform configurations.
> - Used reusable Terraform modules, variables, and outputs to create maintainable and reproducible cloud infrastructure.

---

## License

This project is open source and available under the [MIT License](LICENSE).
