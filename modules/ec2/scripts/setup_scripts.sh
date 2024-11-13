#!/bin/bash
# Update and install necessary packages
yum update -y
yum install -y nodejs npm postgresql16 git nginx docker
service docker start
usermod -aG docker ec2-user # add ec2-user so docker group so sudo isn't needed
newgrp docker # Make the new group membership take effect immediately

# Log file for verification (optional)
LOG_FILE="/home/ec2-user/setup_log.txt"
echo "Starting setup script..." > $LOG_FILE

cd /home/ec2-user

# Clone the Flytrap UI production branch
git clone -b production https://github.com/2408-Team-3/flytrap_ui.git ui

# Generate JWT secret key (TODO: get from secrets manager)
JWT_SECRET_KEY=$(openssl rand -hex 32)

# Log environment variables (partial for sensitive values)
echo "FLASK_ENV=production" >> $LOG_FILE
echo "PGUSER=${db_user}" >> $LOG_FILE
echo "PGHOST=${db_host}" >> $LOG_FILE
echo "PGDATABASE=${db_name}" >> $LOG_FILE
echo "Database Password starts with: ${db_password}" >> $LOG_FILE
echo "JWT Secret Key starts with: ${JWT_SECRET_KEY}" >> $LOG_FILE
echo "AWS_REGION=${aws_region}" >> $LOG_FILE
echo "USAGE_PLAN_ID=${api_gateway_usage_plan_id}" >> $LOG_FILE

# Authenticate Docker to AWS ECR (this assumes the IAM role is correctly attached to the instance)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 266735799562.dkr.ecr.us-east-1.amazonaws.com

# Pull the latest Docker image for the API from ECR
docker pull 266735799562.dkr.ecr.us-east-1.amazonaws.com/flytrap-api-repo:latest

# Start Docker container and pass the environment variables dynamically
docker run -d --name flytrap_api_container -p 8000:8000 \
    -e "FLASK_APP=flytrap.py" \
    -e "FLASK_ENV=production" \
    -e "PGUSER=${db_user}" \
    -e "PGHOST=${db_host}" \
    -e "PGDATABASE=${db_name}" \
    -e "PGPASSWORD=${db_password}" \
    -e "PGPORT=5432" \
    -e "JWT_SECRET_KEY=${JWT_SECRET_KEY}" \
    -e "HTTPONLY=True" \
    -e "SECURE=True" \
    -e "SAMESITE=None" \
    -e "USAGE_PLAN_ID=${api_gateway_usage_plan_id}" \
    -e "AWS_REGION=${aws_region}" \
    266735799562.dkr.ecr.us-east-1.amazonaws.com/flytrap-api-repo:latest

# Connect to the db_user and run schema.sql to setup tables
docker exec -i flytrap_api_container psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /app/schema.sql

# Ensure ec2-user has the correct permissions for the cloned repositories
sudo chown -R ec2-user:ec2-user /home/ec2-user/ui
sudo chmod -R 755 /home/ec2-user/ui

# Set permissions for node_modules before running npm install
# This ensures ec2-user can create and write to node_modules
sudo mkdir -p /home/ec2-user/ui/node_modules
sudo chown -R ec2-user:ec2-user /home/ec2-user/ui/node_modules

cd /home/ec2-user/ui

# Install UI dependencies and build the React app
npm install
# npm run build

# Insert nginx setup script as variable and make executable
echo "${setup_nginx_script}" > /home/ec2-user/setup_nginx.sh
chmod +x /home/ec2-user/setup_nginx.sh
/home/ec2-user/setup_nginx.sh