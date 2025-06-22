# outputs.tf

################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  value       = aws_vpc.vpc.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.vpc.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.vpc.default_security_group_id
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_vpc.vpc.default_route_table_id
}

################################################################################
# Subnets
################################################################################

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = values(aws_subnet.private)[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = values(aws_subnet.private)[*].arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = values(aws_subnet.private)[*].cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = values(aws_subnet.public)[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = values(aws_subnet.public)[*].arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = values(aws_subnet.public)[*].cidr_block
}

################################################################################
# Route Tables
################################################################################

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = [aws_route_table.private.id]
}

output "public_route_table_ids" {
  description = "List of IDs of the public route tables"
  value       = [aws_route_table.public.id]
}

################################################################################
# Gateways
################################################################################

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "internet_gateway_arn" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.igw.arn
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "nat_eip_id" {
  description = "The ID of the Elastic IP address for the NAT Gateway"
  value       = aws_eip.nat.id
}

################################################################################
# Additional Useful Outputs
################################################################################

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = aws_vpc.vpc.owner_id
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = aws_vpc.vpc.enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = aws_vpc.vpc.enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = aws_vpc.vpc.main_route_table_id
}