#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y nginx apache2-utils

# Create password file
sudo htpasswd -cb /etc/nginx/htpasswd admin admin123

# Create simple site
sudo tee /etc/nginx/sites-available/k8s-dashboard >/dev/null <<'EOF'
server {
    listen 7999;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8888/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        auth_basic "Kubernetes Dashboard";
        auth_basic_user_file /etc/nginx/htpasswd;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/k8s-dashboard \
    /etc/nginx/sites-enabled/k8s-dashboard

sudo systemctl enable nginx
sudo systemctl restart nginx