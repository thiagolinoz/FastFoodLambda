variable "region_default" {
  default = "us-east-1"
}

variable "project_name" {
  default = "postech-fiap-fastfood"
}

variable "cidr_block_vpc" {
  default = "10.0.0.0/16"
}

variable "tags" {
  default = {
    Name = "fastfood-3"
  }
}

variable "role_lab" {
 // default = "arn:aws:iam::318969550207:role/LabRole"
  default = "arn:aws:iam::387847618404:role/LabRole"
}

variable "host_elb" {
  default = "http://a31fe34d98ebf477f9e1235d4d71acf7-221921312.us-east-1.elb.amazonaws.com"
}