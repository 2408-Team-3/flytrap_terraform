#!/bin/bash
# Update and install necessary packages
yum update -y
yum install -y nodejs npm
yum install -y python3-pip
yum install -y postgresql
yum install -y git
yum install -y nginx
pip install gunicorn

# Clone the UI and API repositories
cd /home/ec2-user && git clone https://github.com/2408-Team-3/flytrap_ui.git ui
git clone https://github.com/2408-Team-3/flytrap_api.git api

# Set up the Flask backend virtual environment
cd /home/ec2-user/api && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

# Install UI dependencies and build the React app
cd /home/ec2-user/ui && npm install
npm run build

# Set up the database schema for Flask
cd /home/ec2-user/api && psql -h ${db_host} -U ${db_user} -d ${db_name} -f /home/ec2-user/api/schema.sql

# Insert scripts as variables and make them executable
echo "${setup_env_script}" > /home/ec2-user/setup_env.sh
echo "${setup_nginx_script}" > /home/ec2-user/setup_nginx.sh
echo "${setup_gunicorn_script}" > /home/ec2-user/setup_gunicorn.sh

chmod +x /home/ec2-user/setup_env.sh
/home/ec2-user/setup_env.sh
chmod +x /home/ec2-user/setup_nginx.sh
/home/ec2-user/setup_nginx.sh
chmod +x /home/ec2-user/setup_gunicorn.sh
/home/ec2-user/setup_gunicorn.sh