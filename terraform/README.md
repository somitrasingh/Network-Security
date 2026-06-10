# Terraform: AWS Infrastructure for the Network-Security Inference Service

Provisions everything needed to run the containerized FastAPI phishing-detection
service (the app in the repo root) on AWS ECS Fargate.

## What this provisions

| Resource | Purpose |
|---|---|
| ECR repository | Stores the Docker image; scans on push, keeps last 10 images |
| S3 bucket | Model artifacts (versioned, encrypted, all public access blocked) |
| CloudWatch log group | Container stdout/stderr, 14-day retention |
| IAM execution role | Lets ECS pull the image and write logs |
| IAM task role | Lets the *app* read/write the artifacts bucket — nothing else |
| ECS cluster + task definition + service | Runs the container on Fargate (0.25 vCPU / 512 MiB, 1 task) |
| Security group | Inbound on the app port (8000), all outbound |

**Architecture:** the image lives in ECR; an ECS Fargate service in your
account's **default VPC** runs one copy of it. The task gets a public IP
(`assign_public_ip = true`) because default-VPC subnets have no NAT gateway —
the public IP is how the task pulls its image and how you reach the API.
Logs stream to CloudWatch; model files live in S3, accessible only via the
task role. No load balancer — this is a single-task dev/portfolio setup.

All names derive from the `project_name` variable; the AWS account ID is looked
up at plan time (`aws_caller_identity`) — nothing is hardcoded.

## Prerequisites

- Terraform >= 1.9 (`terraform version`)
- AWS CLI configured with credentials (`aws sts get-caller-identity` should work)
- An AWS account (a personal/dev account is fine)
- Docker, for building and pushing the image

## Deploying

```bash
cd terraform
terraform init
terraform plan      # review what will be created
terraform apply     # type "yes" to confirm
```

### First deploy: the image chicken-and-egg

The task definition references an image in ECR, but the ECR repository doesn't
exist until Terraform creates it. So the first deploy is a three-step dance:

1. **`terraform apply`** — creates everything, including the ECR repo. The ECS
   service will start, fail to pull the (nonexistent) image, and keep retrying.
   That's expected and harmless.

2. **Build and push the image** (run from the `terraform/` directory; the
   Dockerfile is in the repo root, hence `..` as build context):

   ```bash
   ECR_URL=$(terraform output -raw ecr_repository_url)

   # Log Docker in to your private registry (the part of the URL before the first /)
   aws ecr get-login-password --region us-east-1 \
     | docker login --username AWS --password-stdin "${ECR_URL%%/*}"

   # On Apple Silicon add: --platform linux/amd64 (Fargate runs amd64 by default)
   docker build -t networksecurity ..

   docker tag networksecurity:latest "${ECR_URL}:v1"
   docker push "${ECR_URL}:v1"
   ```

3. **Re-apply with the new tag** so the task definition points at the image you
   just pushed:

   ```bash
   terraform apply -var="image_tag=v1"
   ```

   (Or set `image_tag = "v1"` in `terraform.tfvars`.) ECS rolls out a new task
   within a minute or two. Find its public IP under
   *ECS → cluster → service → task → Networking*, then open
   `http://<public-ip>:8000/docs`.

For every later release: build, tag (`v2`, `v3`, …), push, bump `image_tag`,
re-apply.

## Cost safety ⚠️

A running Fargate task bills **continuously** (~$9–10/month at 0.25 vCPU /
512 MiB in us-east-1), plus small charges for ECR storage and CloudWatch. When
you're done experimenting:

```bash
terraform destroy
```

This removes everything, including the ECR images (`force_delete = true`) and
the S3 bucket contents are *not* auto-deleted — empty the bucket first if
destroy fails on it (`aws s3 rm s3://<bucket> --recursive`). To pause without
destroying, set `desired_count = 0` and re-apply.

## Next step: migrating local state to an S3 backend

State currently lives in a local `terraform.tfstate` file (gitignored — it can
contain sensitive values). For anything beyond solo experimentation, move it to
S3 so it's durable and locked against concurrent runs:

1. Create a dedicated state bucket (versioned, encrypted) — manually or in a
   separate tiny Terraform config. Don't manage the state bucket in the same
   config whose state it stores.
2. Uncomment the `backend "s3"` block in `versions.tf` and fill in your bucket:

   ```hcl
   backend "s3" {
     bucket       = "<your-terraform-state-bucket>"
     key          = "networksecurity/terraform.tfstate"
     region       = "us-east-1"
     encrypt      = true
     use_lockfile = true  # S3-native locking — no DynamoDB table needed (Terraform >= 1.10)
   }
   ```

3. Migrate the existing state:

   ```bash
   terraform init -migrate-state
   ```

Terraform copies the local state into the bucket; subsequent plans/applies read
and lock it there. Verify with `terraform plan` (should show no changes), then
delete the leftover local `terraform.tfstate*` files.

## Notes

- `terraform.tfvars` is committed on purpose: it holds only non-secret example
  values. Never put secrets in it.
- The security group allows `0.0.0.0/0` ingress on the app port — fine for a
  demo, but restrict the CIDR or front the service with an ALB for anything real.
