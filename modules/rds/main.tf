resource "aws_db_subnet_group" "flytrap_db_subnet_group" {
  name       = "flytrap-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "flytrap-db-subnet-group"
  }
}

resource "aws_security_group" "flytrap_db_sg" {
  name        = "flytrap-db-sg"
  description = "Allow access to the Flytrap database"
  vpc_id      = var.vpc_id

  ingress {
    from_port         = 5432
    to_port           = 5432
    protocol          = "tcp"
    cidr_blocks       = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      var.private_subnet_cidrs[0],
      var.private_subnet_cidrs[1],
      var.public_subnet_cidr
    ]
  }
}

data "aws_secretsmanager_secret" "flytrap_db_secret" {
  name = var.db_secret_name
}

data "aws_secretsmanager_secret_version" "flytrap_db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.flytrap_db_secret.id
}

resource "aws_db_instance" "flytrap_db" {
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.flytrap_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.flytrap_db_sg.id]
  username               = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["username"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["password"]
  db_name                = var.db_name
  skip_final_snapshot    = true # change to false for production (makes a db backup)

  tags = {
    Name = "flytrap-db"
  }
}