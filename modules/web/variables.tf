variable "environment" {
  description = "Environment name (dev, uat, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs for ECS + ALB"
  type        = list(string)
}

variable "container_image" {
  description = "Docker image in ECR"
  type        = string
}

variable "desired_count" {
  description = "ECS desired task count"
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "Fargate task CPU"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Fargate task memory"
  type        = string
  default     = "1024"
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 14
}

variable "ecs_task_execution_role_name" {
  description = "ECS execution role name"
  type        = string
  default     = "ecsTaskExecutionRole"
}