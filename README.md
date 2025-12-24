Network Security & Phishing Detection Web App
Overview

This project is a Python-based web application designed to analyze network and phishing-related data and identify potentially malicious activity. It provides a simple web interface for viewing results and uses automated workflows for data ingestion, validation, and deployment.

The project also demonstrates practical DevOps experience through a CI/CD pipeline implemented using GitLab CI.

Features

Detection and analysis of phishing and network security data

Flask-based web application for result visualization

Automated data ingestion and validation

Containerized deployment using Docker

CI/CD automation with GitLab CI

Modular and maintainable backend design

Problem Statement

Phishing attacks and malicious network activity are common security threats. Manual inspection of large volumes of network data is inefficient and error-prone.

This application automates the process of:

Processing incoming network or phishing datasets

Identifying suspicious patterns

Presenting results through a lightweight web interface

Technology Stack

Language: Python

Web Framework: Flask

Data Processing: Pandas, NumPy

Containerization: Docker

CI/CD: GitLab CI

Frontend: HTML, CSS (Flask templates)

Project Structure
Network-Security/
│
├── app.py                  # Flask application entry point
├── main.py                 # Core processing and detection logic
├── push_data.py            # Data ingestion script
├── Network_Data/           # Raw network / phishing datasets
├── valid_data/             # Cleaned and validated data
├── templates/              # HTML templates
├── Dockerfile              # Docker configuration
├── .gitlab-ci.yml          # GitLab CI/CD pipeline
├── requirements.txt        # Python dependencies
└── README.md

Application Flow

Network or phishing data is ingested using backend scripts.

The data is validated and preprocessed before analysis.

Detection logic identifies suspicious or malicious patterns.

Results are rendered in the Flask web interface.

GitLab CI automates build, test, and deployment steps.

CI/CD Pipeline

The project uses GitLab CI to automate:

Docker image builds

Basic validation and testing

Consistent deployment across environments

This reduces manual intervention and ensures repeatable deployments.

Running Locally
Prerequisites

Python 3.8 or higher

Docker

Git

Steps

Clone the repository:

git clone https://github.com/somitrasingh/Network-Security.git
cd Network-Security


Install dependencies:

pip install -r requirements.txt


Run the application:

python app.py


Access the application at:

http://localhost:5000

Running with Docker
docker build -t network-security-app .
docker run -p 5000:5000 network-security-app

Learning Outcomes

Practical experience with network security data analysis

Building backend web applications using Flask

Implementing CI/CD pipelines with GitLab CI

Containerizing applications using Docker

Applying modular and maintainable design principles

Future Improvements

Integrate machine learning models for advanced phishing detection

Add authentication and access control

Deploy to a cloud platform such as AWS

Add logging and monitoring
