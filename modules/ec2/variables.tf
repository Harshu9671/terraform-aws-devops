# EC2 Module - Input Variables

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource tagging"
  type        = string
  default     = "terraform-aws-devops"
}

variable "key_name" {
  description = "Name of the SSH key pair (leave empty to skip)"
  type        = string
  default     = ""
}
