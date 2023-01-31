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
    Name = "Public web ${count.index + 1}"
  }
}

#private subnet 
# Create Web Public Subnet
resource "aws_subnet" "app-subnet-1" {
  count             = length(var.web_app_cidr)
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = element(var.web_app_cidr, count.index)
  availability_zone = element(var.AZ, count.index)
  #  map_public_ip_on_launch = true

  tags = {
    Name = "Private app ${count.index + 1}"
  }
}
# IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "PROJ VPC IG"
  }
}

# public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}
# RT association
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.web_subnet_cidr)
  subnet_id      = element(aws_subnet.web-subnet-1[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}