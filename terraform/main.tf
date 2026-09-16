data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main"
  }
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)

  subnets = {
    for index, availability_zone in local.availability_zones : availability_zone => {
      availability_zone = availability_zone
      public_cidr       = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, index * 2)
      private_cidr      = cidrsubnet(aws_vpc.main-vpc.cidr_block, 8, index * 2 + 1)
    }
  }
}

resource "aws_subnet" "public" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.public_cidr

  tags = {
    Name = "${each.value.availability_zone}-public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = each.value.availability_zone
  cidr_block        = each.value.private_cidr

  tags = {
    Name = "${each.value.availability_zone}-private"
  }
}
