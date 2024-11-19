#!/bin/bash

sudo curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
sudo yum update -y
sudo yum install -y nodejs postgresql16 git nginx docker
sudo service docker start
sudo usermod -aG docker ec2-user
newgrp docker

cd /home/ec2-user
git clone -b production https://github.com/2408-Team-3/flytrap_ui.git ui

sudo docker pull public.ecr.aws/f4k2o6f2/flytrap-api-public:latest

sudo docker run -d --name flytrap_api_container -p 8000:8000 \
    -e "FLASK_APP=flytrap.py" \
    -e "FLASK_ENV=production" \
    -e "PGUSER=${db_user}" \
    -e "PGHOST=${db_host}" \
    -e "PGDATABASE=${db_name}" \
    -e "PGPASSWORD=${db_password}" \
    -e "PGPORT=5432" \
    -e "JWT_SECRET_KEY=${jwt_secret_key}" \
    -e "HTTPONLY=True" \
    -e "SECURE=True" \
    -e "SAMESITE=None" \
    -e "USAGE_PLAN_ID=${api_gateway_usage_plan_id}" \
    -e "AWS_REGION=${aws_region}" \
    public.ecr.aws/f4k2o6f2/flytrap-api-public:latest

sudo docker exec -i flytrap_api_container psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /app/schema.sql

echo "VITE_FLYTRAP_SDK_URL=${sdk_url}" >> /home/ec2-user/ui/.env

cd /home/ec2-user/ui
npm install
npm run build

echo "${setup_nginx_script}" | sudo tee /home/ec2-user/setup_nginx.sh > /dev/null
sudo chmod +x /home/ec2-user/setup_nginx.sh
sudo /home/ec2-user/setup_nginx.sh