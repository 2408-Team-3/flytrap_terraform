output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.flytrap_vpc.id
}

output "public_subnet_id" {
  description = "VPC public subnets IDs"
  value       = aws_subnet.public_a.id
}

output "private_subnet_ids" {
  description = "VPC private subnets IDS"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "private_subnet_cidrs" {
  description = "VPC private subnet CIDR blocks"
  value       = [aws_subnet.private_a.cidr_block, aws_subnet.private_b.cidr_block]
}

output "public_subnet_cidr" {
  description = "VPC private subnet CIDR block"
  value       = aws_subnet.public_a.cidr_block
}