resource "aws_key_pair" "app-key-pair" {
  key_name   = "app-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "app-key-pair.pem"
}

# Web server key pair
resource "tls_private_key" "web_server_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "web_server_key" {
  content  = tls_private_key.web_server_rsa.private_key_pem
  filename = "web_server_key.pem"
}

resource "aws_key_pair" "web_server_key_pair" {
  key_name   = "web_server_key_pair"
  public_key = tls_private_key.web_server_rsa.public_key_openssh
}

# Database server key pair
resource "tls_private_key" "db_server_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "db_server_key" {
  content  = tls_private_key.db_server_rsa.private_key_pem
  filename = "db_server_key.pem"
}

resource "aws_key_pair" "db_server_key_pair" {
  key_name   = "db_server_key_pair"
  public_key = tls_private_key.db_server_rsa.public_key_openssh
}

# Zabbix server key pair
resource "tls_private_key" "zabbix_server_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "zabbix_server_key" {
  content  = tls_private_key.zabbix_server_rsa.private_key_pem
  filename = "zabbix_server_key.pem"
}

resource "aws_key_pair" "zabbix_server_key_pair" {
  key_name   = "zabbix_server_key_pair"
  public_key = tls_private_key.zabbix_server_rsa.public_key_openssh
}