terraform {
  backend "s3" {
    bucket = "postech-fiap-fastfood-backend-1"
    key    = "backend/tfstate/terraform.tfstate"
    region = "us-east-1"
  }
}
