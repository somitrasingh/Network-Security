FROM python:3.10-slim-bullseye

WORKDIR /app
COPY . /app

# Install system dependencies (optional, lightweight)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI via pip (stable and fast)
RUN pip install --no-cache-dir awscli

# Install app dependencies
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "app.py"]
