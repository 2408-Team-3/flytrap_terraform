resource "aws_vpc" "flytrap_vpc" {
  cidr_block = var.vpc_cidr # set IP address range for VPC
  enable_dns_support = true # allow AWS DNS server to resolve domain names
  enable_dns_hostnames = true # allow VPC's public IP to resolve to DNS domain name

  tags = {
    Name = "flytrap-vpc"
  }
}