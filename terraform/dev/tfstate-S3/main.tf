resource "aws_s3_bucket" "my_bucket" {
  bucket = "marketboro-tf-state-bucket" # Replace with your desired bucket name
  acl    = "private" # Set the access control list for the bucket (optional, use as per your requirements)

  tags = {
    Name = "My Terraform State Bucket"
    Environment = "Production"
  }
}