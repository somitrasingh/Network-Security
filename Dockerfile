FROM python:3.10-slim-buster

WORKDIR /app
COPY . /app

# Use apt-get, install prerequisites, and clean up to reduce image size
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    awscli \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "app.py"]
