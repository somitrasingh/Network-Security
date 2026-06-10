# versions.tf
# Pins the Terraform CLI and AWS provider versions so anyone running this
# configuration (including CI) gets a known-compatible toolchain. The pessimistic
# constraint (~> 5.0) allows 5.x minor/patch upgrades but blocks a future 6.0
# with breaking changes.

terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote state backend — documented next step, intentionally NOT enabled.
  # State currently lives in a local terraform.tfstate file. To migrate to S3,
  # uncomment the block below, fill in your bucket, and run:
  #   terraform init -migrate-state
  # See README.md ("Migrating state to S3") for the full walkthrough.
  # Note: use_lockfile (S3-native locking, no DynamoDB table) requires
  # Terraform >= 1.10.
  # ---------------------------------------------------------------------------
  # backend "s3" {
  #   bucket       = "<your-terraform-state-bucket>"
  #   key          = "networksecurity/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}
