#!/bin/bash
# Update and install necessary packages
yum update -y
yum install -y nodejs npm postgresql16 git nginx docker
service docker start
usermod -aG docker ec2-user # add ec2-user so docker group so sudo isn't needed
newgrp docker # Make the new group membership take effect immediately


# Clone the UI and API repositories
cd /home/ec2-user
git clone https://github.com/2408-Team-3/flytrap_ui.git ui
git clone https://github.com/2408-Team-3/flytrap_api.git api

# Ensure ec2-user has the correct permissions for the cloned repositories
sudo chown -R ec2-user:ec2-user /home/ec2-user/ui
sudo chown -R ec2-user:ec2-user /home/ec2-user/api

# Set up the Flask backend virtual environment
# cd /home/ec2-user/api && sudo python3 -m venv venv && sudo chown -R ec2-user:ec2-user venv && source venv/bin/activate && python3 -m pip install --upgrade pip && python3 -m pip install gunicorn && python3 -m pip install -r requirements.txt

# Set up the Flask backend virtual environment
# cd /home/ec2-user/api
# sudo python3 -m venv venv
# sudo chown -R ec2-user:ec2-user venv  # Ensure ec2-user has access to venv
# source venv/bin/activate && \
# python3 -m pip install --upgrade pip && \
# python3 -m pip install gunicorn && \
# python3 -m pip install -r requirements.txt

# Install UI dependencies and build the React app
cd /home/ec2-user/ui
npm install
npm run build

# Connect to db and run sql script to create tables
cd /home/ec2-user/api && PGPASSWORD="${db_password}" psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /home/ec2-user/api/schema.sql

# Create .env file in api folder
echo "${setup_env_script}" > /home/ec2-user/setup_env.sh
chmod +x /home/ec2-user/setup_env.sh
/home/ec2-user/setup_env.sh

# Create Dockerfile in API folder if it doesn't already exist
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

# Insert scripts as variables and make them executable
echo "${setup_nginx_script}" > /home/ec2-user/setup_nginx.sh
# echo "${setup_gunicorn_script}" > /home/ec2-user/setup_gunicorn.sh
chmod +x /home/ec2-user/setup_nginx.sh
/home/ec2-user/setup_nginx.sh
# chmod +x /home/ec2-user/setup_gunicorn.sh
# /home/ec2-user/setup_gunicorn.sh