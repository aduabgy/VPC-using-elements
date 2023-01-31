# create eip
# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.public_subnet_asso
  ]
  vpc = true
  tags = {
    Name = "Nat-Gateway-EIP"
  }
}

# Creating a NAT Gateway!
# resource "aws_nat_gateway" "NAT_GATEWAY" {
#   depends_on = [
#     aws_eip.Nat-Gateway-EIP
#   ]

#   # Allocating the Elastic IP to the NAT Gateway!
#   allocation_id = aws_eip.Nat-Gateway-EIP.id

#   # Associating it in the Public Subnet!
#   subnet_id = element(var.web_subnet_cidr, count.index)
#   tags = {
#     Name = "Nat-Gateway_Project"
#   }
# }