# providers.tf
# Configures the AWS provider. default_tags are applied automatically to every
# taggable resource this configuration creates, so cost reports and the console
# always show who owns a resource without repeating tags on each block.

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
