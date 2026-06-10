# s3.tf
# Private bucket for ML model artifacts (preprocessor.pkl, model.pkl, etc.).
# Versioning keeps a history of model files so a bad upload can be rolled back;
# public access is fully blocked and objects are encrypted at rest.

resource "aws_s3_bucket" "artifacts" {
  # Bucket names are globally unique across all AWS accounts, so the account ID
  # (looked up via data source, never hardcoded) is appended to avoid collisions.
  bucket = "${var.project_name}-artifacts-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Blocks every path by which the bucket or its objects could be made public.
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption with S3-managed keys (AES256) — free, no KMS key to manage.
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
