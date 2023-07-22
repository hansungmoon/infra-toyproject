terraform {
  backend "s3" {
    bucket = "marketboro-tf-state-bucket"
    key    = "dev/tfstate-S3/terraform.tfstate"
    region = "ap-northeast-2"
  }
}