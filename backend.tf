terraform {
  backend "s3" {
    bucket         = "remote-backend-ak"
    key            = "aws-vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

