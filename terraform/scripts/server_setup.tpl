#!/bin/bash
sudo apt -y remove needrestart
# Update the system
sudo apt-get update -y
sudo apt-get install -y python3-venv python3-dev nginx libpq-dev build-essential curl

# Set needed environment variables
echo "export DB_HOST='${db_sv_ip}'" >> /home/ubuntu/.bashrc
echo "export DB_URL='postgresql://${db_sv_ip}/${db_name}?user=${db_user}&password=${db_pass}'" >> /home/ubuntu/.ENV_VARS
# Get public ip from AWS metadata
echo "export PUBLIC_IP='$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)'" >> /home/ubuntu/.ENV_VARS
# Go to home directory
cd /home/ubuntu
# Create a .DJANGO_SECRET_KEY file with a random secret key
echo "export SECRET_KEY='$(openssl rand -hex 40)'" >> /home/ubuntu/.ENV_VARS
# Copy the .ENV_VARS content to end of .bashrc
cat /home/ubuntu/.ENV_VARS >> /home/ubuntu/.bashrc
# Restart bash
source /home/ubuntu/.bashrc

git clone https://github.com/RicardoRibeiroRodrigues/get-it-django
python3 -m venv env
. env/bin/activate
# Gunicorn with envs from .ENV_VARS
source /home/ubuntu/.ENV_VARS
echo $DB_URL
echo $PUBLIC_IP

cd get-it-django
pip install -r requirements.txt

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
sudo systemctl enable nginx
sudo systemctl restart nginx

# Guacamole client
echo "PubkeyAcceptedKeyTypes +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
echo "KexAlgorithms +diffie-hellman-group14-sha1" | sudo tee -a /etc/ssh/sshd_config
echo "HostKeyAlgorithms +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh

# For last: wait for db to be ready, and run migrations
cd /home/ubuntu/get-it-django
until python manage.py migrate; do
  echo "Aguarda banco." >> /home/ubuntu/wait_db.log
  sleep 10
done

echo "Banco pronto." >> /home/ubuntu/wait_db.log

# Install Zabbix Agent

wget https://cdn.zabbix.com/zabbix/binaries/stable/6.2/6.2.9/zabbix_agent-6.2.9-linux-3.0-amd64-static.tar.gz
sudo dpkg -i zabbix_agent-6.2.9-linux-3.0-amd64-static.tar.gz
sudo apt update

sudo apt install zabbix-agent -y

sudo sed -i 's/Server=127.0.0.1/Server=${zabbix_ip}/' /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/ServerActive=127.0.0.1/ServerActive=${zabbix_ip}/' /etc/zabbix/zabbix_agentd.conf

sudo sed -i 's/Hostname=Zabbix server/Hostname=WebServer/' /etc/zabbix/zabbix_agentd.conf

sudo sed -i 's/# TLSConnect=unencryp/TLSConnect=psk/' /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/# TLSAccept=unencrypted/TLSAccept=psk/' /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/# TLSPSKIdentity=/TLSPSKIdentity=PSK 002/' /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/# TLSPSKFile/TLSPSKFile=/etc/zabbix/zabbix_agentd.psk/' /etc/zabbix/zabbix_agentd.conf

sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
sudo systemctl restart zabbix-agent