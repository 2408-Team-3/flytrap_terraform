#!/bin/bash

# Write .env file with necessary environment variables
cat <<EOF > /home/ec2-user/api/.env
FLASK_APP="flytrap.py"
FLASK_ENV="development"
PGUSER="error_monitoring"
PGHOST="localhost"
PGDATABASE="flytrap_db"
PGPASSWORD="teamthree"
PGPORT="5432"
JWT_SECRET_KEY="SECRET"
HTTPONLY="True"
SECURE="False"
SAMESITE="Strict"
PATH="/"
EOF

# Ensure correct permissions on the .env file
chmod 644 /home/ec2-user/api/.env