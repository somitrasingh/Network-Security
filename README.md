# Network Security — Phishing Detection ML Pipeline

## Overview

An end-to-end machine learning project that detects phishing websites from
network/URL features. It covers the full ML lifecycle: data ingestion from
MongoDB, schema validation, transformation, model training with experiment
tracking, and a FastAPI inference service — containerized with Docker,
deployed to AWS ECS Fargate, with all cloud infrastructure defined as code
in Terraform.

---

## Features

* **End-to-end training pipeline** — ingestion → validation → transformation → training, each stage producing versioned artifacts
* **Data ingestion from MongoDB** with schema validation and drift reporting
* **Experiment tracking** with MLflow (via DagsHub)
* **FastAPI inference service** — upload a CSV, get predictions rendered as a table; interactive docs at `/docs`
* **Containerized** with Docker
* **CI/CD** with GitHub Actions (build → push to Amazon ECR → deploy)
* **Infrastructure as Code** — full AWS stack (ECR, ECS Fargate, S3, IAM, CloudWatch) provisioned with Terraform ([`terraform/`](terraform/README.md))

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Python 3.10 |
| ML | scikit-learn, pandas, NumPy |
| Experiment tracking | MLflow + DagsHub |
| Data store | MongoDB Atlas |
| API | FastAPI + Uvicorn |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Cloud | AWS (ECS Fargate, ECR, S3, IAM, CloudWatch) |
| IaC | Terraform |

---

## Architecture

```
                    ┌─────────────── Training ───────────────┐
MongoDB Atlas ──► Data Ingestion ──► Validation ──► Transformation ──► Model Trainer
                                        │                                  │
                                  drift report                    MLflow (DagsHub)
                                                                           │
                                                                  model.pkl / preprocessor.pkl
                                                                           │
                    ┌─────────────── Serving ────────────────┐             ▼
User ──► FastAPI (/predict) ──► preprocessor + model ──► predictions   S3 (artifacts)

                    ┌─────────────── Delivery ───────────────┐
GitHub push ──► GitHub Actions ──► Docker build ──► ECR ──► ECS Fargate (Terraform-provisioned)
```

---

## Project Structure

```
Network-Security/
│
├── app.py                      # FastAPI app (train + predict endpoints)
├── main.py                     # Run the training pipeline stage-by-stage
├── push_data.py                # Load the raw dataset into MongoDB
├── networksecurity/            # Core package
│   ├── components/             #   data_ingestion, data_validation,
│   │                           #   data_transformation, model_trainer
│   ├── pipeline/               #   training pipeline orchestration
│   ├── entity/                 #   config & artifact dataclasses
│   ├── cloud/                  #   S3 artifact sync
│   ├── constant/               #   pipeline constants
│   ├── exception/ logging/     #   custom exception & logging
│   └── utils/                  #   common + ML utilities (metrics, estimator)
├── Network_Data/               # Raw phishing dataset (CSV)
├── data_schema/                # Expected schema for validation
├── templates/                  # HTML template for prediction results
├── terraform/                  # AWS infrastructure as code (see its README)
├── .github/workflows/main.yml  # CI/CD pipeline
├── Dockerfile
└── requirements.txt
```

---

## Getting Started

### Prerequisites

* Python 3.10+
* A MongoDB Atlas cluster (free tier works)
* Docker (optional, for containerized runs)

### Setup

```bash
git clone https://github.com/somitrasingh/Network-Security.git
cd Network-Security

python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Create a `.env` file in the project root (never committed — it's gitignored):

```
MONGODB_URL_KEY=<your MongoDB connection string>
```

### Load the dataset into MongoDB

```bash
python push_data.py
```

### Train the model

```bash
python main.py
```

Runs ingestion → validation → transformation → training and writes the model
artifacts (`model.pkl`, `preprocessor.pkl`) plus a data-drift report.

### Serve predictions

```bash
python app.py
```

Open `http://localhost:8000/docs`, then:

* `GET /train` — retrain the model through the full pipeline
* `POST /predict` — upload a CSV of URL features, get predictions back as a table

---

## Running with Docker

```bash
docker build -t networksecurity .
docker run -p 8000:8000 --env-file .env networksecurity
```

---

## Deployment (AWS)

All AWS infrastructure is defined in [`terraform/`](terraform/README.md):
an ECR repository, an S3 artifacts bucket, least-privilege IAM roles, a
CloudWatch log group, and an ECS Fargate service — with no hardcoded
credentials or account IDs anywhere in the code.

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

See the [Terraform README](terraform/README.md) for the full deploy
walkthrough (image build & push, rollout, cost notes, and state-backend
migration).

The GitHub Actions workflow (`.github/workflows/main.yml`) handles CI/CD:
on every push to `main` it builds the Docker image (tagged with the commit
SHA and `latest`), pushes it to ECR, and rolls the ECS service so Fargate
picks up the new image. AWS credentials live only in GitHub repository secrets.

---

## Learning Outcomes

* Structuring an ML project as a modular, artifact-driven pipeline
* Data validation and drift detection for ML reliability
* Experiment tracking with MLflow
* Serving models behind a FastAPI service
* Provisioning cloud infrastructure with Terraform (least-privilege IAM, ECS Fargate)
* CI/CD automation with GitHub Actions and Docker

---

## Author

Somitra Singh Kushwah
Email: [somitrasinghkushwah@gmail.com](mailto:somitrasinghkushwah@gmail.com)
LinkedIn: [https://linkedin.com/in/somitra-singh-kushwah](https://linkedin.com/in/somitra-singh-kushwah)
