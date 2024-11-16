#!/bin/bash

yum update -y
yum install -y nodejs npm postgresql16 git nginx docker aws-cli
service docker start
usermod -aG docker ec2-user
newgrp docker

# Fetch the AWS Account ID using AWS CLI
aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)

cd /home/ec2-user
git clone -b production https://github.com/2408-Team-3/flytrap_ui.git ui

# Generate JWT secret key (TODO: get from secrets manager)
JWT_SECRET_KEY=$(openssl rand -hex 32)

# Store the JWT_SECRET_KEY in AWS Secrets Manager
aws secretsmanager create-secret --name flytrap/jwt_secret_key \
    --description "JWT secret key for Flytrap application" \
    --secret-string "${JWT_SECRET_KEY}" \
    --region "${aws_region}" \
aws secretsmanager update-secret --secret-id flytrap/jwt_secret_key \
    --secret-string "$JWT_SECRET_KEY" \
    --region "${aws_region}"

docker pull public.ecr.aws/u3q8a7r6/flytrap_api/sns_branch:latest

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
    -e "AWS_ACCOUNT_ID=${aws_account_id}" \
    public.ecr.aws/u3q8a7r6/flytrap_api/sns_branch:latest

docker exec -i flytrap_api_container psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /app/schema.sql

sudo chown -R ec2-user:ec2-user /home/ec2-user/ui
sudo chmod -R 755 /home/ec2-user/ui
sudo mkdir -p /home/ec2-user/ui/node_modules
sudo chown -R ec2-user:ec2-user /home/ec2-user/ui/node_modules

cd /home/ec2-user/ui
npm install
echo "VITE_FLYTRAP_SDK_URL=${sdk_url}" > .env
npm run build

echo "${setup_nginx_script}" > /home/ec2-user/setup_nginx.sh
chmod +x /home/ec2-user/setup_nginx.sh
/home/ec2-user/setup_nginx.sh