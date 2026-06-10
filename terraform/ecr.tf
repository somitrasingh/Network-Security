# ecr.tf
# Private container registry for the inference service image. Images are
# vulnerability-scanned on every push, and a lifecycle policy caps stored
# images so old builds don't accumulate storage cost forever.

resource "aws_ecr_repository" "this" {
  name = var.project_name

  image_scanning_configuration {
    scan_on_push = true
  }

  # Allows `terraform destroy` to delete the repo even when it still contains
  # images. Fine for a dev/portfolio stack; remove in production to protect
  # images from accidental deletion.
  force_delete = true
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last ${var.ecr_keep_last_images} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_keep_last_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
