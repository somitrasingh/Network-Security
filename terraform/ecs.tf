# ecs.tf
# The compute layer: an ECS cluster, the Fargate task definition describing the
# container, a security group for the task's network interface, and the service
# that keeps the desired number of tasks running.

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  # Container Insights adds detailed CPU/memory metrics but bills per metric;
  # disabled to keep the dev stack cheap. Flip to "enabled" if you want them.
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# Security group attached to each task's elastic network interface (ENI).
resource "aws_security_group" "service" {
  name        = "${var.project_name}-service-sg"
  description = "Allow inbound traffic to the ${var.project_name} container"
  vpc_id      = data.aws_vpc.default.id

  # Open to the internet so the demo API is reachable directly by public IP.
  # For production, restrict the CIDR or put an ALB in front instead.
  ingress {
    description = "App traffic to the container port"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Unrestricted egress: the task must reach ECR (image pull), CloudWatch Logs,
  # S3, and the app's external dependencies (e.g. MongoDB Atlas).
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.project_name
  requires_compatibilities = ["FARGATE"]

  # awsvpc is mandatory on Fargate: each task gets its own ENI with a private
  # (and optionally public) IP, so the container port is exposed directly —
  # no host-port mapping like on EC2.
  network_mode = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  # Execution role: lets ECS pull the ECR image and ship logs.
  # Task role: the AWS credentials the app code sees (S3 artifact access).
  execution_role_arn = aws_iam_role.task_execution.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = "${aws_ecr_repository.this.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      # Tells the app which S3 bucket to sync artifacts/models to, so the
      # bucket name is never hardcoded in application code.
      environment = [
        {
          name  = "TRAINING_BUCKET_NAME"
          value = aws_s3_bucket.artifacts.bucket
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.service.id]

    # Default-VPC subnets have no NAT gateway, so the task needs a public IP
    # both to pull its image from ECR and to be reachable from the internet.
    assign_public_ip = true
  }
}
