#!/bin/bash

sudo apt -y remove needrestart

# Aceitar automaticamente a atualização do kernel
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::options::="--force-confold" dist-upgrade

# Atualizar o sistema
sudo apt update && sudo apt upgrade -y

# Instalar Apache, MySQL, PHP e outras dependências
sudo apt install apache2 mysql-server php php-pear php-cgi php-common libapache2-mod-php php-mbstring php-net-socket php-gd php-xml-util php-mysql php-bcmath -y

# Instalar o repositório do Zabbix
wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu22.04_all.deb
sudo dpkg -i zabbix-release_6.2-2+ubuntu22.04_all.deb
sudo apt update

# Instalar o Zabbix Server, Frontend e Agent
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# Configurar o MySQL para o Zabbix
sudo mysql <<EOF
CREATE DATABASE zabbix character set utf8mb4 collate utf8mb4_bin;
CREATE USER zabbix@localhost IDENTIFIED BY '${zabbix_pass}';
GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost;
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EOF

# Importar as tabelas do Zabbix
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql --default-character-set=utf8mb4 -uzabbix --password='password' zabbix

# Desativar a opção log_bin_trust_function_creators
sudo mysql <<EOF
SET GLOBAL log_bin_trust_function_creators = 0;
QUIT;
EOF

# Configurar a senha do Zabbix no arquivo de configuração
sudo sed -i 's/^# DBPassword=$/DBPassword=password/' /etc/zabbix/zabbix_server.conf

# Reiniciar serviços
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2

# Instalar pacote de idioma inglês
sudo apt install language-pack-en -y

# Configurações do banco de dados
DB_HOST="localhost"
DB_NAME="zabbix"
DB_USER="zabbix"
DB_PASSWORD="${zabbix_pass}"

# Configuração do Zabbix frontend
FRONTEND_HOST="localhost"
FRONTEND_NAME="Zabbix Server"
FRONTEND_LANGUAGE="en_US"

# Navegue até o diretório onde está localizado o setup.php
cd /usr/share/zabbix

# Crie um arquivo de configuração temporário para o setup.php
cat <<EOF > setup.conf
<?php
\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = '$DB_HOST';
\$DB['PORT']     = '3306';
\$DB['DATABASE'] = '$DB_NAME';
\$DB['USER']     = '$DB_USER';
\$DB['PASSWORD'] = '$DB_PASSWORD';
\$ZBX_SERVER      = '$FRONTEND_HOST';
\$ZBX_SERVER_NAME = '$FRONTEND_NAME';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_URL  = 'http://$FRONTEND_HOST/zabbix';
\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
\$ZBX_MESSAGES_LOG = '/var/log/zabbix/zabbix_server.log';
\$ZBX_MESSAGES_LOG_DETAILS = '/var/log/zabbix/zabbix_server.log';
\$ZBX_WITH_JAVASCRIPT = true;
\$ZBX_SERVER_PORT_JSITEMS = '10052';
\$ZBX_SERVER_NAME_JSITEMS = 'Zabbix Server';
\$ZBX_API_CORS = '*';
\$ZBX_DEFAULT_LANGUAGE = '$FRONTEND_LANGUAGE';
?>
EOF

# Execute o setup.php usando o interpretador PHP com o arquivo de configuração temporário
sudo php setup.php --conf setup.conf

# Remova o arquivo de configuração temporário
rm setup.conf

