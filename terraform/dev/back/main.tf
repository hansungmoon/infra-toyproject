resource "aws_s3_bucket" "my_bucket" {
  bucket = "marketboro-tf-state-bucket" # Replace with your desired bucket name
  acl    = "private" # Set the access control list for the bucket (optional, use as per your requirements)

  tags = {
    Name = "My Terraform State Bucket"
    Environment = "Production"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock" # Replace with your desired table name
  billing_mode   = "PAY_PER_REQUEST"      # Use PAY_PER_REQUEST for on-demand capacity
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Production"
  }
}