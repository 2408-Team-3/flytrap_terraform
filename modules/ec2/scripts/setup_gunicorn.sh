#!/bin/bash
# Write Gunicorn service file
cat <<EOF > /etc/systemd/system/gunicorn.service
[Unit]
Description=Gunicorn instance to serve Flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/api
ExecStart=/home/ec2-user/api/venv/bin/gunicorn --workers 1 --bind 127.0.0.1:5000 flytrap:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Gunicorn
sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl start gunicorn