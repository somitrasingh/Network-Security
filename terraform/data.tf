# data.tf
# Looks up existing AWS resources instead of hardcoding IDs/ARNs. The default
# VPC and its subnets host the Fargate tasks (cheap for a dev environment — no
# custom VPC or NAT gateway needed), and the caller identity supplies the
# account ID used to make the S3 bucket name globally unique.

# The account's default VPC (every new AWS account has one per region).
data "aws_vpc" "default" {
  default = true
}

# All subnets in the default VPC. Default-VPC subnets are public (route to an
# internet gateway), which is what lets assign_public_ip = true work.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Identity of the credentials running Terraform — used for the account ID.
data "aws_caller_identity" "current" {}
