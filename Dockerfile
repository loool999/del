FROM python:3.11-slim

WORKDIR /app

# Install pip dependencies (requirements.txt is copied first for better caching)
COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app

# Expose the port the app listens on
EXPOSE 8080

# Ensure output is logged straight to the console
ENV PYTHONUNBUFFERED=1

# Run the application
CMD ["python", "main.py"]
