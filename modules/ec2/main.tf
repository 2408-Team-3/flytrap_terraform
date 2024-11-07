resource "aws_iam_role" "ec2_role" {
  name               = "EC2RoleForRDSAccess"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_permissions_policy" {
  name        = "EC2PermissionsPolicy"
  description = "Policy to allow EC2 instance to access RDS and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "rds:DescribeDBInstances",
          "rds:Connect",
          "rds:ExecuteStatement",
        ]
        Effect   = "Allow"
        Resource = var.db_arn
      },
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_rds_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_permissions_policy.arn
}

resource "aws_security_group" "flytrap_app_sg" {
  name        = "allow_http_https"
  description = "Allow HTTP, HTTPS and RDS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.flytrap_db_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "flytrap_app" {
  ami             = var.ami
  instance_type   = "t2.micro"
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.flytrap_app_sg.id]

  iam_instance_profile = aws_iam_role.ec2_role.name

  tags = {
    Name = "FlytrapApp"
  }

  associate_public_ip_address = true
}