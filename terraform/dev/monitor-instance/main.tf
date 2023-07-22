resource "aws_instance" "example_instance" {
  ami           = "ami-070374d0235f6e013"
  instance_type = "t2.micro"
  key_name      = "monitor"
  associate_public_ip_address = true

  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.public_sg_id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnets[0]

}


############################## data #####################################
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "marketboro-tf-state-bucket"
    key    = "dev/vpc/terraform.tfstate"
    region = "ap-northeast-2"
  }
}