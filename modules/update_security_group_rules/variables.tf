variable "rds_security_group_id" {
  description = "RDS security group ID"
  type        = string
}

variable "ec2_security_group_id" {
  description = "EC2 security group ID"
  type        = string
}

variable "lambda_security_group_id" {
  description = "Lambda security group ID"
  type        = string
}