resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-vpc"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = { for idx, subnet in var.subnets : idx => subnet }

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.private_cidr
  availability_zone = each.value.az

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = "${var.name}-${var.environment}-private-subnet-${each.value.az}"
    }
  )
}

resource "aws_subnet" "public" {
  for_each = { for idx, subnet in var.subnets : idx => subnet }

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.public_cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = "${var.name}-${var.environment}-public-subnet-${each.value.az}"
    }
  )
}