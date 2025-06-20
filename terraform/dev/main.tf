# Get available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Use the first 2 AZs if not specified
locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)
  cluster_name = var.cluster_name != "" ? var.cluster_name : "${var.project_name}-${var.environment}"
}

module "vpc" {
  source = "../modules/vpc"

  name        = var.project_name
  environment = var.environment

  # Network Configuration
  vpc_cidr               = var.vpc_cidr
  availability_zones     = local.azs
  private_subnet_cidrs   = var.private_subnet_cidrs
  public_subnet_cidrs    = var.public_subnet_cidrs

  # EKS Configuration
  cluster_name         = local.cluster_name
  pod_cidr_blocks      = var.pod_cidr_blocks
  service_cidr_block   = var.service_cidr_block

  # Security Configuration
  security_level                = var.security_level
  trusted_cidr_blocks           = var.trusted_cidr_blocks
  monitoring_enabled            = var.monitoring_enabled
  monitoring_cidr_blocks        = var.monitoring_cidr_blocks
  container_registry_endpoints  = var.container_registry_endpoints
  allowed_dns_servers           = var.allowed_dns_servers

  # NAT Gateway Configuration
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # VPC Flow Logs
  enable_flow_log = var.enable_flow_log

  # Additional Rules
  additional_worker_ingress_rules = var.additional_worker_ingress_rules
  additional_worker_egress_rules  = var.additional_worker_egress_rules

  # Legacy SSH Support
  enable_ssh_access      = var.enable_ssh_access
  ssh_source_cidr_blocks = var.ssh_source_cidr_blocks

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Owner       = "DevOps Team"
  }
}
