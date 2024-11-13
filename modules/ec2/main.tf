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
      },
      {
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Effect": "Allow",
        "Resource": var.db_secret_arn
      },
      {
        Action    = "ec2-instance-connect:SendSSHPublicKey"
        Effect    = "Allow"
        Resource  = "arn:aws:ec2:${var.region}:${var.account_id}:instance/${aws_instance.flytrap_app.id}"
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

  # Allow HTTP access from Lambda (via security group)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.lambda_sg_id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS access from Lambda (via security group)
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.lambda_sg_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.flytrap_db_sg_id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = var.public_subnet_id
  route_table_id = aws_route_table.public.id
}

data "aws_secretsmanager_secret" "flytrap_db_secret" {
  name = var.db_secret_name
}

data "aws_secretsmanager_secret_version" "flytrap_db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.flytrap_db_secret.id
}

locals {
  db_user     = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["username"]
  db_password = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["password"]
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfileForRDSAccess"
  role = aws_iam_role.ec2_role.name
}

locals {
  setup_nginx_script    = file("${path.module}/scripts/setup_nginx.sh")
  setup_env_script      = file("${path.module}/scripts/setup_env.sh")
}

resource "aws_instance" "flytrap_app" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  security_groups             = [aws_security_group.flytrap_app_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  # for ssh
  associate_public_ip_address = true
  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }

  user_data = templatefile("${path.module}/scripts/setup_scripts.sh", {
    setup_env_script          = local.setup_env_script
    setup_nginx_script        = local.setup_nginx_script
    db_host                   = var.db_host
    db_user                   = local.db_user
    db_name                   = var.db_name
    db_password               = local.db_password
    api_gateway_usage_plan_id = var.api_gateway_usage_plan_id
    region                    = var.region
    JWT_SECRET_KEY            = var.JWT_SECRET_KEY
  })

  tags = {
    Name = "FlytrapApp"
  }
}