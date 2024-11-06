variable "vpc_id" {
  description = "Flytrap VPC id"
  type        = string
}

variable "public_subnet_id" {
  description = "Flytrap public subnet id"
  type        = string
}

variable "flytrap_db_sg_id" {
  description = "Flytrap RDS database security group id"
  type        = string
}

variable "db_arn" {
  description = "Flytrap RDS database ARN"
  type        = string
}