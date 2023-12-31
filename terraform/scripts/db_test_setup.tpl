#!/bin/bash

sudo chmod 755 /home/ubuntu
# Switch to the PostgreSQL user
cd /tmp
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${db_pass}';"

# Create a new PostgreSQL database and user
sudo -u postgres psql -c "CREATE DATABASE ${db_name};"
sudo -u postgres psql -c "CREATE USER ${db_user} WITH PASSWORD '${db_pass}';"
sudo -u postgres psql -c "ALTER ROLE ${db_user} SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE ${db_user} SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE ${db_user} SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${db_name} TO ${db_user};"


# Enable remote connections (optional, for development purposes)
# Replace 0.0.0.0/0 with your specific IP range for security
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/*/main/postgresql.conf

# Restart PostgreSQL for changes to take effect
sudo service postgresql restart

echo "PostgreSQL setup completed."

# Install Guacamole client
echo "Installing Guacamole client..."

echo "PubkeyAcceptedKeyTypes +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config
echo "KexAlgorithms +diffie-hellman-group14-sha1" | sudo tee -a /etc/ssh/sshd_config
echo "HostKeyAlgorithms +ssh-rsa" | sudo tee -a /etc/ssh/sshd_config

sudo systemctl restart ssh