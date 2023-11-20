#!/bin/bash
sudo apt -y remove needrestart
# Update the system
sudo apt-get update -y
sudo apt-get install -y python3-venv python3-dev nginx libpq-dev build-essential curl

# Set needed environment variables
echo "export DB_HOST='${db_sv_ip}'" >> /home/ubuntu/.bashrc
echo "export DB_URL='postgresql://${db_sv_ip}/${db_name}?user=${db_user}&password=${db_pass}'" >> /home/ubuntu/.bashrc
# Get public ip from AWS metadata
echo "export PUBLIC_IP='$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)'" >> /home/ubuntu/.bashrc
# Restart bash
source /home/ubuntu/.bashrc

# Go to home directory
cd /home/ubuntu
# Create a .DJANGO_SECRET_KEY file with a random secret key
echo "export SECRET_KEY='$(openssl rand -hex 40)'" > .DJANGO_SECRET_KEY
source .DJANGO_SECRET_KEY
git clone https://github.com/RicardoRibeiroRodrigues/get-it-django
python3 -m venv env
. env/bin/activate
cd get-it-django
pip install -r requirements.txt
python manage.py migrate

sudo mkdir -pv /var/{log,run}/gunicorn/
sudo chown -cR ubuntu:ubuntu /var/{log,run}/gunicorn/
# Start gunicorn
gunicorn -c config/gunicorn/dev.py

# Add config to nginx
sudo cat > /etc/nginx/sites-available/get-it-django <<'EOF'
server_tokens               off;
access_log                  /var/log/nginx/get-it-django.access.log;
error_log                   /var/log/nginx/get-it-django.error.log;

server {
  listen                    80;
  location / {
    proxy_pass              http://localhost:8000;
    proxy_set_header        Host $host;
  }

  location /static {
    autoindex on;
    alias /var/www/getit.com/static/;
  }
}
EOF

cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/get-it-django .
# Remove default nginx config
sudo rm default

sudo mkdir -pv /var/www/getit.com/static/
sudo chown -cR ubuntu:ubuntu /var/www/getit.com/static/
cd /home/ubuntu/get-it-django
python manage.py collectstatic --noinput

# Restart nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Guacamole client
echo "PubkeyAcceptedKeyTypes +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
echo "KexAlgorithms +diffie-hellman-group14-sha1" | sudo tee -a /etc/ssh/sshd_config
echo "HostKeyAlgorithms +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh