terraform {
  backend "s3" {
    bucket         = "diogenes-terraform-state"
    key            = "diogenes-web/dev/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}