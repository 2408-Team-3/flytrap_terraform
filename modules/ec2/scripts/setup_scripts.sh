#!/bin/bash
# Update and install necessary packages
yum update -y
yum install -y nodejs npm
yum install -y python3-pip
yum install -y postgresql16
yum install -y git
yum install -y nginx

# Clone the UI and API repositories
cd /home/ec2-user && git clone https://github.com/2408-Team-3/flytrap_ui.git ui
git clone https://github.com/2408-Team-3/flytrap_api.git api

# Ensure ec2-user has the correct permissions for the cloned repositories
sudo chown -R ec2-user:ec2-user /home/ec2-user/ui
sudo chown -R ec2-user:ec2-user /home/ec2-user/api

# Set up the Flask backend virtual environment
# cd /home/ec2-user/api && sudo python3 -m venv venv && sudo chown -R ec2-user:ec2-user venv && source venv/bin/activate && python3 -m pip install --upgrade pip && python3 -m pip install gunicorn && python3 -m pip install -r requirements.txt

# Set up the Flask backend virtual environment
cd /home/ec2-user/api
sudo python3 -m venv venv
sudo chown -R ec2-user:ec2-user venv  # Ensure ec2-user has access to venv
source venv/bin/activate && \
python3 -m pip install --upgrade pip && \
python3 -m pip install gunicorn && \
python3 -m pip install -r requirements.txt

# Install UI dependencies and build the React app
cd /home/ec2-user/ui && npm install
npm run build

# Set up the database schema for Flask
# experimenting with quotes here
#cd /home/ec2-user/api && PGPASSWORD="${db_password}" psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /home/ec2-user/api/schema.sql

cd /home/ec2-user/api &&. sudo -u postgres PGPASSWORD="${db_password}" psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f /home/ec2-user/api/schema.sql

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