# Create VPC
resource "aws_vpc" "application_vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Application VPC"
  }
}

# Create Subnet
resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = "10.0.0.0/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Application Subnet"
  }
}

# Create Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "app_gateway" {
  vpc_id = aws_vpc.application_vpc.id
}

# Create a route table for the public subnet
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.application_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_gateway.id
  }

  tags = {
    Name = "Application Internet Gateway"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "subnet_route_table_association" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_route_table.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway" {
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.app_subnet.id
}

# Create a route table for the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.application_vpc.id

  tags = {
    Name = "Application Private Route Table"
  }
}

# Add a default route to the NAT Gateway in the private route table
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
