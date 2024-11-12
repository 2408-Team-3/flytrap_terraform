resource "aws_vpc" "flytrap_vpc" {
  cidr_block           = var.vpc_cidr # set IP address range for VPC
  enable_dns_support   = true # allow AWS DNS server to resolve domain names
  enable_dns_hostnames = true # allow VPC's public IP to resolve to DNS domain name

  tags = {
    Name = "flytrap-vpc"
  }
}

data "aws_availability_zones" "available" {} # fetches AZs;

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.flytrap_vpc.id # id of vpc above
  cidr_block              = var.public_subnet_cidr[0] # set IP range for the public subnet
  availability_zone       = data.aws_availability_zones.available.names[0] # set AZ
  map_public_ip_on_launch = true # all instances on public subnet get a public IP

  tags = {
    Name = "flytrap-public-subnet-a" # this shows up as the public subnet name in AWS
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.flytrap_vpc.id # id of vpc above
  cidr_block        = var.private_subnet_cidrs[0] # set IP range for the private subnet
  availability_zone = data.aws_availability_zones.available.names[0] # set AZ

  tags = {
    Name = "flytrap-private-subnet-a" # this shows up as the private subnet name in AWS
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.flytrap_vpc.id # id of vpc above
  cidr_block        = var.private_subnet_cidrs[1] # set IP range for the private subnet
  availability_zone = data.aws_availability_zones.available.names[1] # set AZ

  tags = {
    Name = "flytrap-private-subnet-b" # this shows up as the private subnet name in AWS
  }
}
