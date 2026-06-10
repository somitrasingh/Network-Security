# outputs.tf
# Values you need after apply: the ECR URL for docker tag/push, names for the
# AWS CLI/console, and the task role ARN for verifying IAM scope.

output "ecr_repository_url" {
  description = "Full ECR repository URL — use as the target for docker tag/push."
  value       = aws_ecr_repository.this.repository_url
}

output "artifacts_bucket_name" {
  description = "S3 bucket holding model artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service running the app."
  value       = aws_ecs_service.this.name
}

output "task_role_arn" {
  description = "ARN of the IAM role the application code assumes at runtime."
  value       = aws_iam_role.task.arn
}
