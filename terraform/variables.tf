# variables.tf
# Every tunable value for the stack. Defaults are sized for a cheap single-task
# dev environment; override anything in terraform.tfvars or with -var on the CLI.

variable "aws_region" {
  description = "AWS region to deploy all resources into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short lowercase name used to derive resource names (ECR repo, cluster, roles, log group). Must be a valid ECR repository name."
  type        = string
  default     = "networksecurity"
}

variable "environment" {
  description = "Environment label applied as a tag to all resources (e.g. dev, staging)."
  type        = string
  default     = "dev"
}

variable "image_tag" {
  description = "Tag of the container image in ECR that the ECS task should run. Update this after pushing a new image and re-apply to deploy it."
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port the FastAPI app listens on inside the container. app.py binds uvicorn to 8000."
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU). Must be a valid Fargate CPU/memory combination with task_memory."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB. Must pair with task_cpu (256 CPU supports 512–2048 MiB)."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of task copies the ECS service keeps running."
  type        = number
  default     = 1
}

variable "ecr_keep_last_images" {
  description = "How many images the ECR lifecycle policy retains; older images are expired automatically to control storage cost."
  type        = number
  default     = 10
}

variable "log_retention_days" {
  description = "How long CloudWatch keeps container logs before deleting them."
  type        = number
  default     = 14
}
