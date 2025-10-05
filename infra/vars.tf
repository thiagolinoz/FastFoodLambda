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
  default = "http://a989b3c862ead4778999cb40899ec157-1366353186.us-east-1.elb.amazonaws.com"
}
