# syntax=docker/dockerfile:1
FROM python:3.11-slim AS builder

WORKDIR /src

# Install git, git-lfs, curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates curl && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y --no-install-recommends git-lfs && \
    git lfs install && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy your repo into builder
COPY . /src

# Pull LFS files so they are real content, not pointer files
RUN git lfs pull

# Final runtime image
FROM python:3.11-slim

WORKDIR /app

# Copy everything from builder, including LFS files
COPY --from=builder /src /app

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080
ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]
