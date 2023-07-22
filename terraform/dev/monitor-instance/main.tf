resource "aws_instance" "example_instance" {
  ami           = "ami-070374d0235f6e013"
  instance_type = "t2.micro"
  key_name      = "monitor"

  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.public_sg_id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnets

}


############################## data ######################################
data "terraform_remote_state" "vpc" {
  backend = "local"  # Replace with your actual backend configuration if using remote state
  config = {
    path = "../vpc/terraform.tfstate"  # Replace with the correct path to the state file of main.tf No. 1
  }
}