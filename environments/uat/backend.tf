terraform {
  backend "s3" {
    bucket         = "diogenes-terraform-state"
    key            = "diogenes-web/uat/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "diogenes-terraform-locks"
    encrypt        = true
  }
}