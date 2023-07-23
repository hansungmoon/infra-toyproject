terraform {
  backend "s3" {
    bucket = "marketboro-tf-state-bucket"
    key    = "dev/back/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "terraform-state-lock"
    encrypt        = true                  
  }
}