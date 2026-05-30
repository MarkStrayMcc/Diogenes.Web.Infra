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

resource "aws_cloudwatch_log_group" "dev" {
  name              = "/ecs/diogenes-web-dev"
  retention_in_days = 14

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecs_task_definition" "dev" {
  family                   = "diogenes-web-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::707714592196:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "diogenes-web"
      image     = "707714592196.dkr.ecr.eu-west-2.amazonaws.com/diogenes-web:618bc646b5138514142eb8ff4d0856f3f8dd4ea6"
      cpu       = 512
      memory    = 1024
      essential = true

      portMappings = [
        {
          name          = "diogenes-web-8080-tcp"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      environment = [
        {
          name  = "ASPNETCORE_URLS"
          value = "http://+:8080"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.dev.name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
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

resource "aws_lb_target_group" "dev" {
  name        = "diogenes-web-targets"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-0f662ffab3ecc56a9"

  health_check {
    enabled  = true
    protocol = "HTTP"
    path     = "/health"
    matcher  = "200"
  }
}

resource "aws_lb_target_group" "uat" {
  name        = "diogenes-web-uat-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-0f662ffab3ecc56a9"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_ecs_service" "dev" {
  name            = "diogenes-web-service"
  cluster         = aws_ecs_cluster.dev.id
  task_definition = aws_ecs_task_definition.dev.arn
  desired_count   = 1

  launch_type                       = "FARGATE"
  availability_zone_rebalancing     = "ENABLED"
  enable_ecs_managed_tags           = true
  enable_execute_command            = false
  health_check_grace_period_seconds = 0
  wait_for_steady_state             = false

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dev.arn
    container_name   = "diogenes-web"
    container_port   = 8080
  }

  network_configuration {
    assign_public_ip = true

    security_groups = [
      aws_security_group.dev_service.id
    ]

    subnets = [
      "subnet-0687e53a7a15cb484",
      "subnet-08f86d45a77a83b12",
      "subnet-09d0573b5e1cd2e80"
    ]
  }
}