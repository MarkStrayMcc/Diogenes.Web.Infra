module "web" {
  source = "../../modules/web"

  environment = "uat"

  aws_region = "eu-west-2"

  vpc_id = "vpc-0f662ffab3ecc56a9"

  subnets = [
    "subnet-0687e53a7a15cb484",
    "subnet-08f86d45a77a83b12",
    "subnet-09d0573b5e1cd2e80"
  ]

  container_image = "707714592196.dkr.ecr.eu-west-2.amazonaws.com/diogenes-web:618bc646b5138514142eb8ff4d0856f3f8dd4ea6"
}