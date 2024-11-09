#!/bin/bash

# Exit on any error
set -e

# Log file setup
LOGFILE="/tmp/nginx_setup.log"
SERVERNAME="genaihackathon.ddns.net"
exec 1> >(tee -a "$LOGFILE") 2>&1

echo "Starting Nginx reverse proxy setup with HTTPS at $(date)"

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo "✔ Success: $1"
    else
        echo "✘ Error: $1"
        echo "Check logs at $LOGFILE"
    fi
}

# Update system packages
echo "Updating system packages..."
sudo apt update -y && sudo apt upgrade -y
check_status "System update"

# Install Nginx and Certbot
echo "Installing Nginx and Certbot..."
sudo apt install -y nginx certbot python3-certbot-nginx
check_status "Nginx and Certbot installation"

# Create necessary directories
echo "Creating necessary directories..."
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled
sudo mkdir -p /etc/nginx/ssl
check_status "Directory creation"

# Generate self-signed SSL certificate (temporary)
echo "Generating self-signed SSL certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$SERVERNAME"
check_status "SSL certificate generation"

# Configure strong SSL parameters
echo "Configuring SSL parameters..."
cat << 'EOF' | sudo tee /etc/nginx/ssl-params.conf
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
add_header Strict-Transport-Security "max-age=63072000" always;
EOF
check_status "SSL parameters configuration"

# Create nginx.conf
echo "Creating nginx.conf..."
cat << 'EOF' | sudo tee /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;
    client_max_body_size 100M;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
check_status "Nginx configuration creation"

# Create reverse proxy configuration with HTTPS support
echo "Creating reverse proxy configuration..."
cat << 'EOF' | sudo tee /etc/nginx/sites-available/default
# HTTP - redirect all traffic to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name _;
    
    # Redirect all HTTP requests to HTTPS
    return 301 https://genaihackathon.ddns.net$request_uri;
}

# HTTPS - proxy requests to application
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name genaihackathon.ddns.net;

    # SSL configuration
    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
    include /etc/nginx/ssl-params.conf;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "strict-origin-strict-when-cross-origin";

    # Proxy headers
    proxy_http_version 1.1;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Proxy timeout settings
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # Reverse proxy to application
    location / {
        proxy_pass http://127.0.0.1:8000;
    }

    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/xml+rss application/atom+xml image/svg+xml;
}
EOF
check_status "Reverse proxy configuration creation"

# Enable default site
echo "Enabling default site..."
sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
check_status "Default site enabling"

# Start and enable Nginx
echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx
check_status "Nginx service startup"

# Configure firewall if running
if command -v firewall-cmd >/dev/null 2>&1; then
    echo "Configuring firewall..."
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --reload
    check_status "Firewall configuration"
fi

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t
check_status "Nginx configuration test"

# Print status and IP information
echo "Installation completed!"
echo "Nginx Status: $(systemctl is-active nginx)"

# Print helpful information
echo "
=== Installation Summary ===
• Nginx is configured as a reverse proxy with HTTPS support
• Your application (port 8000) is accessible via HTTPS
• All HTTP traffic is redirected to HTTPS
• Temporary self-signed SSL certificate is in place

=== Security Features ===
• TLS 1.2 and 1.3 enabled
• Strong SSL cipher configuration
• HTTP/2 enabled
• HSTS enabled
• Security headers configured

=== File Locations ===
• Nginx config: /etc/nginx/nginx.conf
• Site config: /etc/nginx/sites-available/default
• SSL certificates: /etc/nginx/ssl/
• SSL parameters: /etc/nginx/ssl-params.conf
• Access log: /var/log/nginx/access.log
• Error log: /var/log/nginx/error.log

=== Next Steps ===
1. Update your EC2 security group to allow inbound traffic on ports 80 and 443
2. Install a valid SSL certificate using Certbot:
   sudo certbot --nginx -d yourdomain.com
3. Make sure your application is running on port 8000
4. Test both HTTP and HTTPS access

=== Important Commands ===
• Restart Nginx: sudo systemctl restart nginx
• Check status: sudo systemctl status nginx
• View logs: sudo tail -f /var/log/nginx/error.log
• Install SSL certificate: sudo certbot --nginx
• Renew SSL certificate: sudo certbot renew

Installation log saved to: $LOGFILE
"

# sudo useradd -r -s /bin/false nginx
