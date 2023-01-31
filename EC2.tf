# EC2 Public 
resource "aws_instance" "web_server" {
  ami           = "ami-00950d2c99bfd49a6"
  count         = length(var.ec2_cidr)
  instance_type = var.EC_type
  availability_zone = element(var.AZ, count.index)
  tags = {
    Name = "Public web ${count.index + 1}"
  }
}

# EC2 Private  
resource "aws_instance" "app_server" {
  ami           = "ami-00950d2c99bfd49a6"
  count         = length(var.pte_EC2_cidr)
  instance_type = var.EC_type
  availability_zone = element(var.AZ, count.index)
  tags = {
    Name = "Private app ${count.index + 1}"
  }
}