# logs.tf
# CloudWatch log group that receives the container's stdout/stderr via the
# awslogs driver configured in the task definition. Created explicitly (rather
# than letting ECS auto-create it) so retention is controlled and the group is
# cleaned up on destroy.

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.log_retention_days
}
