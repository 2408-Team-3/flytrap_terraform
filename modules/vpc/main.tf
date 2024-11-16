resource "aws_vpc" "flytrap_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "flytrap-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.flytrap_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "flytrap-public-subnet-a"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.flytrap_vpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "flytrap-private-subnet-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.flytrap_vpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "flytrap-private-subnet-b"
  }
}
