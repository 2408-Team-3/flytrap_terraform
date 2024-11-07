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

data "aws_secretsmanager_secret" "flytrap_db_secret" {
  name = var.db_secret_name  # The name of your secret in Secrets Manager
}

data "aws_secretsmanager_secret_version" "flytrap_db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.flytrap_db_secret.id
}

# remove password after flask setup (only need user to run sql script)
locals {
  db_user = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["username"]
  db_password = jsondecode(data.aws_secretsmanager_secret_version.flytrap_db_secret_version.secret_string)["password"]
}

resource "aws_instance" "flytrap_app" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  security_groups             = [aws_security_group.flytrap_app_sg.id]
  iam_instance_profile        = aws_iam_role.ec2_role.name
  associate_public_ip_address = true

  tags = {
    Name = "FlytrapApp"
  }

  provisioner "file" {
    source      = "./scripts/setup_nginx.sh"
    destination = "/home/ec2-user/setup_nginx.sh"
  }

  provisioner "file" {
    source      = "./scripts/setup_gunicorn.sh"
    destination = "/home/ec2-user/setup_gunicorn.sh"
  }

  provisioner "file" {
    source      = "./scripts/setup_env.sh"
    destination = "/home/ec2-user/setup_env.sh"
  }

  # add error handlers here?
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nodejs npm",
      "sudo yum install -y python3-pip",
      "sudo yum install -y postgresql",
      "sudo yum install -y nginx",  # Install Nginx
      "pip install gunicorn",  # Install Gunicorn for serving the Flask app

      # Clone the UI and API repos
      "cd /home/ec2-user && git clone https://github.com/2408-Team-3/flytrap_ui.git ui",
      "git clone https://github.com/2408-Team-3/flytrap_api.git api",

      # Set up Flask backend virtual environment
      "cd /home/ec2-user/api && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt",  # Create and activate virtual env & install dependencies

      # Install UI dependencies and build the React app
      "cd /home/ec2-user/ui && npm install",
      "npm run build",

      # Set up the database schema for Flask
      "cd /home/ec2-user/api && psql -h ${var.db_host} -U ${local.db_user} -d ${var.db_name} -f /home/ec2-user/api/schema.sql",

      "chmod +x /home/ec2-user/setup_env.sh",
      "/home/ec2-user/setup_env.sh",  # Run the script to create the .env file

      "chmod +x /home/ec2-user/setup_nginx.sh",
      "/home/ec2-user/setup_nginx.sh",

      "chmod +x /home/ec2-user/setup_gunicorn.sh",
      "/home/ec2-user/setup_gunicorn.sh",
    ]
  }
}