resource "aws_db_subnet_group" "flytrap_db_subnet_group" {
  name       = "flytrap-db-subnet-group"
  subnet_ids = var.db_subnet_ids # the vpc's two private subnet ids; passed in via module block

  tags = {
    Name = "flytrap-db-subnet-group"
  }
}

resource "aws_security_group" "flytrap_db_sg" {
  name        = "flytrap-db-sg"
  description = "Allow access to the Flytrap database"
  vpc_id      = var.vpc_id

  # change cidr blocks after all modules run
  # ingress and egress should be the ec2 and lambda ips only

  # sets the inbound rule
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change later, after EC2 and lambda are configured
  }

  # sets the outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"] # change later, after EC2 and lambda are configured
  }
}
