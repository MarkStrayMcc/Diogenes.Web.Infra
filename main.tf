resource "aws_ecs_cluster" "dev" {
  name = "diogenes-web-dev"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

resource "aws_ecs_cluster" "uat" {
  name = "diogenes-web-uat"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}