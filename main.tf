# Provider
provider "aws" {
  region = var.REGION
  #   access_key = ""
  #   secret_key = ""	
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "PROJ VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet-1" {
  count             = length(var.web_subnet_cidr)
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = element(var.web_subnet_cidr, count.index)
  availability_zone = element(var.AZ, count.index)
  # map_public_ip_on_launch = true

  tags = {
    Name = "Public Sub ${count.index + 1}"
  }
}

#private subnet 
resource "aws_subnet" "app-subnet-1" {
  count             = length(var.pte_app_cidr)
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = element(var.pte_app_cidr, count.index)
  availability_zone = element(var.AZ, count.index)
  #  map_public_ip_on_launch = true

  tags = {
    Name = "Private Sub ${count.index + 1}"
  }
}
# IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "PROJ VPC IG"
  }
}

# Public Route Tables and association
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "publicRT"
  }
}

# private Route Tables and association with NAT gw
resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.my-vpc.id


  tags = {
    Name = "privateRT"
  }
}

# create eip
# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  vpc = true
  tags = {
    Name = "Nat-Gateway-EIP"
  }
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  subnet_id     = aws_subnet.web-subnet-1[1].id

  tags = {
    Name = "nat gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_subnet.web-subnet-1
  ]
}

# Natgw Route 
resource "aws_route" "natgw_assos" {
  route_table_id         = aws_route_table.privateRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gw.id
}

# EC2 Public 
resource "aws_instance" "web_server" {
  ami           = "ami-00950d2c99bfd49a6"
  count         = length(var.ec2_cidr)
  instance_type = var.EC_type
  # security_groups = ["aws_security_group.TF_SG"]
  availability_zone = element(var.AZ, count.index)
  tags = {
    Name = "Public web ${count.index + 1}"
  }
}

# EC2 Private  
resource "aws_instance" "app_server" {
  ami               = "ami-00950d2c99bfd49a6"
  count             = length(var.pte_EC2_cidr)
  instance_type     = var.EC_type
  availability_zone = element(var.AZ, count.index)
  tags = {
    Name = "Private app ${count.index + 1}"
  }
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}
# resource Local file 
resource "local_file" "TF_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tfkey"
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#security group using terraform
resource "aws_security_group" "TF_SG" {
  name        = "security group using terraform"
  description = "security group using terraform"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "TF_SG"
  }
}