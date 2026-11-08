#!/bin/bash

set -e

dnf update -y

dnf install -y python3 python3-pip

mkdir -p /opt/resiliencelab

cat > /opt/resiliencelab/app.py <<'PYTHON'
${app_source}
PYTHON

python3 -m venv /opt/resiliencelab/venv

/opt/resiliencelab/venv/bin/pip install Flask==3.1.2 gunicorn==23.0.0

cat > /etc/systemd/system/resiliencelab.service <<'SERVICE'
[Unit]
Description=AWS ResilienceLab Flask Application
After=network.target

[Service]
User=root
WorkingDirectory=/opt/resiliencelab
Environment=ENVIRONMENT=production
ExecStart=/opt/resiliencelab/venv/bin/gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 2 \
    app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload

systemctl enable resiliencelab

systemctl start resiliencelab
