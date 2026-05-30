terraform {
  required_version = ">= 1.9"

  backend "s3" {
    bucket         = "diogenes-terraform-state"
    key            = "diogenes-web/prod/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "diogenes-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}