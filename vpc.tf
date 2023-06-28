# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name        = "greenhouse"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

# Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "public"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "private"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

# Internet connection for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "internet gw"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

# Internet connection for private subnets
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidr_blocks)
  vpc   = true

  tags = {
    Name        = "elastic-IP-${count.index}"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_nat_gateway" "main" {
  count = length(var.public_subnet_cidr_blocks)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "nat-gw-${count.index}"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

# Routing traffic
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # traffic from public subnet
  # goes out to the internet through Internet GW.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "public"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr_blocks)

  vpc_id = aws_vpc.main.id

  # traffic from private subnet
  # goes out to the internet 
  # via NAT GW attached to public subnet.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name        = "private-${count.index}"
    environment = var.environment[0]
    terraform   = var.terraform
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr_blocks)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

