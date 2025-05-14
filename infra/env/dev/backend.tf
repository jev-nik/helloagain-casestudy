terraform {
  backend "s3" {
    bucket         = "helloagain-state"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "helloagain-state-lock"
  }
}