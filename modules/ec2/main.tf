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
  user_data                   = <<-EOF
                                #!/bin/bash
                                export AWS_REGION=${var.aws_region}
                                export DB_HOST=${var.db_host}
                                export DB_NAME=${var.db_name}
                                export DB_USER=${local.db_user} #remove
                                export DB_PASS=${local.db_password} #remove
                                export DB_PORT=${var.db_port}
                                EOF

  tags = {
    Name = "FlytrapApp"
  }

  # Cloning repos, installing dependencies, and setting up the DB
  # add error handlers here?
  # move to scripts folder

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nodejs npm",
      "sudo yum install -y python3-pip",
      "sudo yum install -y postgresql",
      "sudo yum install -y nginx",  # Install Nginx

      # Install Gunicorn
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
      "cd /home/ec2-user/api && psql -h ${var.db_host} -U ${db_user} -d ${var.db_name} -f /home/ec2-user/api/schema.sql"

      # Configure Nginx to serve the React frontend and proxy requests to Flask
      "sudo mv /home/ec2-user/ui/dist /usr/share/nginx/html",  # Move the React build files to Nginx's web root
      "sudo bash -c 'echo \"server {
        listen 80;
        server_name flytrap-monitor.com;  # Change to your domain or public IP/ change to variable

        root /usr/share/nginx/html;  # Path to React build files
        index index.html;

        location / {
          try_files $uri /index.html;  # Enable React's client-side routing
        }

        location /api/ {
          proxy_pass http://127.0.0.1:5000;  # Proxy API requests to Flask - is this port correct?
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        }
      }\" > /etc/nginx/conf.d/default.conf'",

      # Restart Nginx to apply the changes
      "sudo systemctl restart nginx"

      # Create Gunicorn systemd service file
      "echo '[Unit]
      Description=Gunicorn instance to serve Flask app
      After=network.target

      [Service]
      User=ec2-user
      Group=ec2-user
      WorkingDirectory=/home/ec2-user/api
      ExecStart=/home/ec2-user/api/venv/bin/gunicorn --workers 1 --bind 0.0.0.0:5000 flytrap:app
      Restart=always

      [Install]
      WantedBy=multi-user.target' > /etc/systemd/system/gunicorn.service",

      # Reload systemd and start the Gunicorn service
      "sudo systemctl daemon-reload",
      "sudo systemctl enable gunicorn",
      "sudo systemctl start gunicorn"
    ]
  }
}