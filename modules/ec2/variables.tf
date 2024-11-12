variable "vpc_id" {
  description = "Flytrap VPC id"
  type        = string
}

variable "account_id" {
  description = "AWS account id"
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

variable "db_name" {
  description = "Flytrap RDS endpoint for db connection"
  type        = string
}

variable "db_secret_name" {
  description = "AWS secret name for database credentials"
  type        = string
}

variable "ami" {
  description = "Amazon Machine Image (AMI) for Amazon Linux"
  type        = string
}

variable "region" {
  description = "AWS region - setting as env variable for db connection in Flask"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN for the db connection secret in Secret Manager"
  type        = string
}

variable "lambda_sg_id" {
  description = "Lambda security group id for webhook connection"
  type        = string
}

variable "db_host" {
  description = "Hostname for the Flytrap RDS database for psql"
  type        = string
}
