#!/bin/bash
# Update and install necessary packages
yum update -y
yum install -y nodejs npm postgresql16 git nginx docker
service docker start
usermod -aG docker ec2-user # add ec2-user so docker group so sudo isn't needed
newgrp docker # Make the new group membership take effect immediately

cd /home/ec2-user
git clone https://github.com/2408-Team-3/flytrap_ui.git ui
git clone -b production https://github.com/2408-Team-3/flytrap_api.git api

# Ensure ec2-user has the correct permissions for the cloned repositories
sudo chown -R ec2-user:ec2-user /home/ec2-user/ui
sudo chown -R ec2-user:ec2-user /home/ec2-user/api

# Install UI dependencies and build the React app
cd /home/ec2-user/ui
npm install
npm run build

# Connect to db and run sql script to create tables
cd /home/ec2-user/api
PGPASSWORD="${db_password}" psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /home/ec2-user/api/schema.sql

JWT_SECRET_KEY=$(openssl rand -hex 32) # get from secret manager

# Directly create .env file with necessary environment variables
cat <<EOF > /home/ec2-user/api/.env
FLASK_APP="flytrap.py"
FLASK_ENV="production"
PGUSER="${db_user}"
PGHOST="${db_host}"
PGDATABASE="${db_name}"
PGPASSWORD="${db_password}"
PGPORT="5432"
JWT_SECRET_KEY="${JWT_SECRET_KEY}"
HTTPONLY="True"
SECURE="True"
SAMESITE="None"
USAGE_PLAN_ID="${api_gateway_usage_plan_id}"
AWS_REGION="${region}"
EOF

# Ensure correct permissions on the .env file
chmod 644 /home/ec2-user/api/.env

# Create .env file in api folder
# echo "${setup_env_script}" > /home/ec2-user/setup_env.sh
# chmod +x /home/ec2-user/setup_env.sh
# /home/ec2-user/setup_env.sh

# Create Dockerfile in API folder
cat <<EOF > /home/ec2-user/api/Dockerfile
# Dockerfile for Flytrap API
FROM python:3.9
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir --upgrade pip && pip install -r requirements.txt
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "flytrap:app"]
EOF

# Build and run the Docker container for the API
cd /home/ec2-user/api
docker build -t flytrap_api .
docker run -d --name flytrap_api_container -p 8000:8000 --env-file .env flytrap_api

# Insert nginx setup script as variable and make executable
echo "${setup_nginx_script}" > /home/ec2-user/setup_nginx.sh
chmod +x /home/ec2-user/setup_nginx.sh
/home/ec2-user/setup_nginx.sh