resource "aws_vpc" "devsecops_vpc" {
  cidr_block = var.vpc_cidr
  tags = merge(var.tags, {
    Name = "${var.Name}-vpc"
    Environment = var.environment
  })
}

resource "aws_subnet" "public_subnet" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.devsecops_vpc.id
  cidr_block              = each.value
  availability_zone       = var.public_subnet_availability_zones[tonumber(each.key)]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment}-public-subnet-${each.key}"
    SubnetType = "public"
  })
}

resource "aws_subnet" "private_subnet" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.devsecops_vpc.id
  cidr_block        = each.value
  availability_zone = var.private_subnet_availability_zones[tonumber(each.key)]

  tags = merge(var.tags, {
    Name = "${var.environment}-private-subnet-${each.key}"
    SubnetType = "private"
  })
}

resource "aws_internet_gateway" "devsecops_igw" {
  vpc_id = aws_vpc.devsecops_vpc.id
  tags = merge(var.tags, {
    Name = "${var.Name}-igw"
    Environment = var.environment
  })
}

resource "aws_route_table" "devsecops_route_table" {
  vpc_id = aws_vpc.devsecops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devsecops_igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-public-route-table"
    Environment = var.environment
  })
}

resource "aws_route_table_association" "public_route_table_assoc" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.devsecops_route_table.id
}
