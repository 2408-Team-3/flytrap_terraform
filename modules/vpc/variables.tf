variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16" # CIDR = Classless Inter-Domain Routing block; this is a common choice
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnets"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"] # changed from 1 and 2
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}