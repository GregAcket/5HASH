######## DATA

data "aws_availability_zones" "available" {
  state = "available"
}


######## LOCALS

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  subnets = {
    for index, availability_zone in local.availability_zones : availability_zone => {
      availability_zone = availability_zone
      public_cidr       = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, index * 2)
      private_cidr      = cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, index * 2 + 1)
    }
  }
}

######## RESSOURCES

### VPC

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

###

### Subnets

resource "aws_subnet" "public" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.public_cidr

  tags = {
    Name = "${each.value.availability_zone}-public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.private_cidr

  tags = {
    Name = "${each.value.availability_zone}-private"
  }
}

###

### Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Internet_gateway"
  }
}

###

### NAT Gateway

resource "aws_nat_gateway" "nat_gateway" {
  for_each = local.subnets

  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${each.value.availability_zone}-nat"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

###

### Eip

resource "aws_eip" "eip" {
  for_each = local.subnets
  domain   = "vpc"

  tags = {
    Name = "${each.value.availability_zone}-eip"
  }
}

###

### Routes
# Public

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private

resource "aws_route_table" "private_route_table" {
  for_each = local.subnets
  vpc_id   = aws_vpc.main_vpc.id
  tags = {
    Name = "${each.value.availability_zone}-private-route-table"
  }
}

resource "aws_route" "private_route" {
  for_each               = local.subnets
  route_table_id         = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[each.key].id
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

###
