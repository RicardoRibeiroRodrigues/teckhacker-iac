# Create an EC2 instance with an Elastic IP
resource "aws_instance" "jump_server" {
    ami           = "ami-06aa3f7caf3a30282" # Ubuntu 20.04 LTS
    instance_type = "t2.small"             
    subnet_id     = aws_subnet.app_subnet.id
    key_name      = aws_key_pair.app-key-pair.key_name
    vpc_security_group_ids = [aws_security_group.js_security_group.id]

    # Allocate and associate an Elastic IP
    associate_public_ip_address = true

    tags = {
        Name = "Jump Server"
    }
}

# Create a security group for the EC2 instance
resource "aws_security_group" "js_security_group" {
  vpc_id = aws_vpc.application_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a security group for the EC2 instances on the local network
resource "aws_security_group" "local_network_security_group" {
  vpc_id = aws_vpc.application_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow communication within the local network
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.application_vpc.cidr_block] 
  }
}

# Create three EC2 instances in the local network
resource "aws_instance" "web_server" {
    ami           = "ami-0fc5d935ebf8bc3bc" # Ubuntu 22.04 LTS
    instance_type = "t2.medium"             
    subnet_id     = aws_subnet.app_subnet.id
    key_name      = aws_key_pair.app-key-pair.key_name
    vpc_security_group_ids = [aws_security_group.local_network_security_group.id]

    tags = {
        Name = "Web Server"
    }
}

resource "aws_instance" "db_server" {
    ami           = "ami-0fc5d935ebf8bc3bc" 
    instance_type = "t2.small"             
    subnet_id     = aws_subnet.app_subnet.id
    key_name      = aws_key_pair.app-key-pair.key_name
    vpc_security_group_ids = [aws_security_group.local_network_security_group.id]

    tags = {
        Name = "Database Server"
    }
}

resource "aws_instance" "zabbix_server" {
    ami           = "ami-0fc5d935ebf8bc3bc" 
    instance_type = "t2.medium"             
    subnet_id     = aws_subnet.app_subnet.id
    key_name      = aws_key_pair.app-key-pair.key_name
    vpc_security_group_ids = [aws_security_group.local_network_security_group.id]

    tags = {
        Name = "Zabbix Server"
    }
}