resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-igw"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-public-rt"
    }
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-nat-gateway"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.environment}-private-rt"
    }
  )
}

resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}