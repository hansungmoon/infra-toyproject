terraform {
  backend "s3" {
    bucket = "marketboro-tf-state-bucket"
    key    = "dev/monitor-instance/terraform.tfstate"
    region = "ap-northeast-2"
  }
}