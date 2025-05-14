resource "aws_s3_bucket" "example" {
    bucket = "helloagain-example-bucket-dev"
    tags = {
      Environment = "dev"
    }
  }