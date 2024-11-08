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

variable "db_host" {
  description = "Flytrap RDS endpoint for db connection"
  type        = string
}

variable "db_name" {
  description = "Flytrap RDS endpoint for db connection"
  type        = string
}

variable "ami" {
  description = "Amazon Machine Image (AMI) for Amazon Linux"
  type        = string
  default     = "ami-06b21ccaeff8cd686" # change? (move to root variables)
}

variable "region" {
  description = "AWS region - setting as env variable for db connection in Flask"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN for the db connection secret in Secret Manager"
  type        = string
}