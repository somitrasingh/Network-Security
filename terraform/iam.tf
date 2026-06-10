# iam.tf
# Two separate roles, both assumable only by the ECS Tasks service:
#
#   * Execution role — used by the ECS *agent* on your behalf to start the task:
#     pull the image from ECR and write logs to CloudWatch. Your code never
#     uses these credentials.
#   * Task role — the credentials your *application code* receives inside the
#     container (via the SDK credential chain). Scoped to exactly the S3 access
#     the app needs and nothing else.

# Shared trust policy: only ECS tasks may assume these roles.
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ------------------------------------------------------------------------------
# Task execution role (infrastructure-side: image pull + log delivery)
# ------------------------------------------------------------------------------

resource "aws_iam_role" "task_execution" {
  name               = "${var.project_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

# AWS-managed policy granting ECR pull and CloudWatch Logs write. This ARN is a
# global AWS constant (the aws:: account), not an account-specific ARN.
resource "aws_iam_role_policy_attachment" "task_execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------------------------------------------------------------
# Task role (application-side: what the FastAPI app itself can do)
# ------------------------------------------------------------------------------

resource "aws_iam_role" "task" {
  name               = "${var.project_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

# Least-privilege S3 access scoped to the artifacts bucket only. Two statements
# because ListBucket acts on the bucket ARN while Get/PutObject act on object
# ARNs (bucket-arn/*) — combining them on one resource would silently not work.
data "aws_iam_policy_document" "task_s3_access" {
  statement {
    sid     = "ObjectReadWrite"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }

  statement {
    sid     = "BucketList"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.artifacts.arn
    ]
  }
}

resource "aws_iam_role_policy" "task_s3_access" {
  name   = "${var.project_name}-s3-artifacts-access"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_s3_access.json
}
