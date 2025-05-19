terraform {
  backend "s3" {
    bucket         = "helloagain-state"
    key            = "terraform.tfstate"
    region         = "${REGION}"
    dynamodb_table = "helloagain-state-lock"
  }
}