ariable "vpc_id" {
  description = "The ID of the VPC in which to create the RDS resources"
  type        = string
}

# Subnet IDs for the database subnet group
#value is passed in via the module block in the root main.tf

variable "db_subnet_ids" {
  description = "A list of subnet IDs for the RDS subnet group"
  type        = list(string)
}