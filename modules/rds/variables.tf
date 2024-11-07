variable "vpc_id" {
  description = "The ID of the VPC in which to create the RDS resources"
  type        = string
}

variable "db_subnet_ids" {
  description = "A list of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "db_secret_name" {
  description = "The name of the AWS Secrets Manager secret containing RDS credentials"
  type        = string
  default     = "flytrap_db_credentials"
}

variable "db_name" {
  description = "The name of the database to connect to"
  type        = string
  default = "flytrap_db"
}

variable "private_subnet_cidrs" {
  description = "VPC's private subnet cidr blocks"
  type        = list(string)
}