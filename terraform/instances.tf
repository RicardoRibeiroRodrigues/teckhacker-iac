data "template_file" "user_data" {
  template = file("scripts/guacamole_sv.tpl")
  vars = {
    # Guacamole Pass
    guacamole_pass = var.GUAC_PASS
    # Web server IP and private key
    webserver_ip          = aws_instance.web_server.private_ip
    webserver_private_key = local_file.web_server_key.content
    # Database server IP and private key
    # db_ip          = aws_db_instance.server_database.address
    db_ip = aws_instance.db_server.private_ip
    db_private_key = local_file.db_server_key.content
    # Zabbix server IP and private key
    zabbix_ip          = aws_instance.zabbix_server.private_ip
    zabbix_private_key = local_file.zabbix_server_key.content
  }
}

# Create an EC2 instance with an Elastic IP
resource "aws_instance" "jump_server" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.app_subnet.id
  key_name               = aws_key_pair.app-key-pair.key_name
  vpc_security_group_ids = [aws_security_group.js_security_group.id]

  # Allocate and associate an Elastic IP
  associate_public_ip_address = true

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "Jump Server"
  }
}

data "template_file" "web_server" {
  template = file("scripts/server_setup.tpl")
  vars = {
    # Database server IP and private key
    # db_sv_ip = aws_db_instance.server_database.address
    db_sv_ip = aws_instance.db_server.private_ip
    db_name  = var.DB_NAME
    db_user  = var.DB_USER
    db_pass  = var.DB_PASS
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.app_subnet.id
  key_name               = aws_key_pair.web_server_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]

  tags = {
    Name = "Web Server"
  }
  # Allocate and associate an Elastic IP
  associate_public_ip_address = true

  user_data = data.template_file.web_server.rendered


  # This resource depends on the database server being created first
  depends_on = [ aws_instance.db_server ]
}

data "template_file" "db_server" {
  template = file("scripts/db_setup.tpl")
  vars = {
    # Database name, user, and password
    db_name = var.DB_NAME
    db_user = var.DB_USER
    db_pass = var.DB_PASS
  }
}


resource "aws_instance" "db_server" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.app_subnet.id
  key_name               = aws_key_pair.db_server_key_pair.key_name
  vpc_security_group_ids = [ aws_security_group.local_network_security_group.id ]

  user_data = data.template_file.db_server.rendered

  tags = {
    Name = "Database Server"
  }
}

resource "aws_instance" "zabbix_server" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.app_subnet.id
  key_name               = aws_key_pair.zabbix_server_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]

  # Allocate and associate an Elastic IP
  associate_public_ip_address = true

  tags = {
    Name = "Zabbix Server"
  }
}