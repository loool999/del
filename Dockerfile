# syntax=docker/dockerfile:1
FROM python:3.11-slim AS builder

ARG GIT_URL=""
ARG GIT_BRANCH="main"
ARG GITHUB_TOKEN=""

WORKDIR /src

# Install git and git-lfs and other small utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates curl && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y --no-install-recommends git-lfs && \
    git lfs install && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone private/public repo and fetch LFS content.
# For private repos we use the token in the URL. Be careful: don't leak token in logs.
RUN if [ -z "$GIT_URL" ]; then echo "GIT_URL not provided"; exit 1; fi

# Use tokenized URL when GITHUB_TOKEN provided (do not expose in final layers)
RUN if [ -n "$GITHUB_TOKEN" ]; then \
      AUTH_URL="$(echo $GIT_URL | sed -E "s#https://#https://${GITHUB_TOKEN}@#")" ; \
      git clone --branch "$GIT_BRANCH" --depth 1 "$AUTH_URL" . ; \
    else \
      git clone --branch "$GIT_BRANCH" --depth 1 "$GIT_URL" . ; \
    fi && \
    git lfs pull --all

# Install Python deps into a clean runtime image
FROM python:3.11-slim

WORKDIR /app

# Copy only the built source from previous stage (no .git)
COPY --from=builder /src /app

# Install runtime dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080
ENV PYTHONUNBUFFERED=1

CMD ["python", "main.py"]
