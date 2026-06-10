# terraform.tfvars
# Concrete values for this dev deployment. These contain no secrets, so the file
# is safe to commit in a portfolio repo. Anything omitted falls back to the
# defaults declared in variables.tf.

aws_region   = "us-east-1"
project_name = "networksecurity"
environment  = "dev"

# Bump this to the tag you pushed (e.g. "v1") and re-apply to deploy it.
image_tag = "latest"

container_port = 8000
task_cpu       = 256
task_memory    = 512
desired_count  = 1

ecr_keep_last_images = 10
log_retention_days   = 14
