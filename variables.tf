# Provider variables 
variable "REGION" {
  default = "eu-west-2"
}
# VPC variables
variable "vpc_cidr" {
  description = "default vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

# public subnet variable 
variable "web_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

#private subnet variable 
variable "web_app_cidr" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}
# availability zones 
variable "AZ" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}