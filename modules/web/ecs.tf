resource "aws_ecs_cluster" "this" {
  name = "diogenes-web-${var.environment}"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecr_repository" "this" {
  name = "diogenes-web"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/diogenes-web-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "diogenes-web-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "diogenes-web"
      image     = var.container_image
      cpu       = tonumber(var.task_cpu)
      memory    = tonumber(var.task_memory)
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
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecs_service" "this" {
  name            = "diogenes-web-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

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
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "diogenes-web"
    container_port   = 8080
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.service.id
    ]
    subnets = var.subnets
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}