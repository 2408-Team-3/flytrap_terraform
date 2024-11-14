#!/bin/bash

yum update -y
yum install -y nodejs npm postgresql16 git nginx docker
service docker start
usermod -aG docker ec2-user
newgrp docker

cd /home/ec2-user
git clone -b production https://github.com/2408-Team-3/flytrap_ui.git ui

# Generate JWT secret key (TODO: get from secrets manager)
JWT_SECRET_KEY=$(openssl rand -hex 32)

docker pull public.ecr.aws/f4k2o6f2/flytrap-api-public:latest

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
    public.ecr.aws/f4k2o6f2/flytrap-api-public:latest

docker exec -i flytrap_api_container psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /app/schema.sql

sudo chown -R ec2-user:ec2-user /home/ec2-user/ui
sudo chmod -R 755 /home/ec2-user/ui
sudo mkdir -p /home/ec2-user/ui/node_modules
sudo chown -R ec2-user:ec2-user /home/ec2-user/ui/node_modules

cd /home/ec2-user/ui
npm install
npm run build

echo "${setup_nginx_script}" > /home/ec2-user/setup_nginx.sh
chmod +x /home/ec2-user/setup_nginx.sh
/home/ec2-user/setup_nginx.sh