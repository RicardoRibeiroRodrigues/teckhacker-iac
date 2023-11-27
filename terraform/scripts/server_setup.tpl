#!/bin/bash
sudo apt -y remove needrestart
# Update the system
sudo apt-get update -y
sudo apt-get install -y python3-venv python3-dev nginx libpq-dev build-essential curl ruby-full

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

# Put start_gunicorn.sh in /home/ubuntu
sudo cat > /home/ubuntu/start_gunicorn.sh <<'EOF'
#!/bin/bash
sudo killall gunicorn
cd /home/ubuntu/
source env/bin/activate
source .ENV_VARS
cd get-it-django
gunicorn -c config/gunicorn/dev.py
EOF
sudo chmod a+x /home/ubuntu/start_gunicorn.sh

git clone https://github.com/RicardoRibeiroRodrigues/get-it-django
python3 -m venv env
. env/bin/activate
# Gunicorn with envs from .ENV_VARS
source /home/ubuntu/.ENV_VARS

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

wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb
sudo apt update
sudo apt install zabbix-agent -y

sudo sed -i "s/Server=127.0.0.1/Server=${zabbix_ip}/" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=${zabbix_ip}/" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/Hostname=Zabbix server/Hostname=${name}/" /etc/zabbix/zabbix_agentd.conf

sudo systemctl restart zabbix-agent

# Download and install CodeDeploy agent
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start