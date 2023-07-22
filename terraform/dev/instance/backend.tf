terraform {
  backend "s3" {
    bucket = "marketboro-tf-state-bucket"
    key    = "dev/instance/terraform.tfstate"
    region = "ap-northeast-2"
  }
}