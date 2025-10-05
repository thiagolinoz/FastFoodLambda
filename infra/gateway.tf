resource "aws_internet_gateway" "igw" {
  vpc_id = data.terraform_remote_state.eks_vpc.outputs.vpc_id
  tags   = var.tags
}
