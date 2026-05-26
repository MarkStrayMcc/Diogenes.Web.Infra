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

resource "aws_ecr_repository" "diogenes_web" {
  name = "diogenes-web"
}

resource "aws_security_group" "alb" {
  name        = "diogenes-alb-sg"
  description = "Diogenes LB SG"
  vpc_id      = "vpc-0f662ffab3ecc56a9"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dev_service" {
  name        = "diogenes-web-service-sg"
  description = "Created in ECS Console"
  vpc_id      = "vpc-0f662ffab3ecc56a9"

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
