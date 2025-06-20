module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.enable_flow_log
  flow_log_destination_type            = var.enable_flow_log ? "cloud-watch-logs" : null

  tags = local.common_tags

  public_subnet_tags  = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags

  nat_gateway_tags = local.common_tags
  igw_tags         = local.common_tags

  public_route_table_tags  = merge(local.common_tags, { Name = "${var.name}-${var.environment}-public-rt" })
  private_route_table_tags = merge(local.common_tags, { Name = "${var.name}-${var.environment}-private-rt" })
}