FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy code
COPY . /app

# Install Git and Git LFS
RUN apt-get update && apt-get install -y git git-lfs \
    && git lfs install

# Pull LFS files
RUN git lfs pull

# Expose Cloud Run port
EXPOSE 8080

# Ensure console logging
ENV PYTHONUNBUFFERED=1

# Run the Flask app
CMD ["python", "main.py"]
