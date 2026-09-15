# --- Root Module ---
# Orchestrates the networking and EC2 modules

# --- Networking ---
module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  project_name       = var.project_name
}

# --- EC2 ---
module "ec2" {
  source = "./modules/ec2"

  instance_type = var.instance_type
  subnet_id     = module.networking.public_subnet_id
  vpc_id        = module.networking.vpc_id
  project_name  = var.project_name
  key_name      = var.key_name
}
