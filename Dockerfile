# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP run.py
ENV DEBUG True

ENV DB_ENGINE="mysql" 
ENV DB_USERNAME="username"
ENV DB_PASS="password"
ENV DB_HOST="localhost"
ENV DB_PORT="3306"
ENV DB_NAME="dbname"


# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
    gcc \
    python3-dev \
    libmariadb-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mysql-connector-python

# Copy application code
COPY . .

# Install and run Flask database migration commands
RUN pip install python-dotenv && \
    dotenv run flask db init && \
    dotenv run flask db migrate && \
    dotenv run flask db upgrade



# Gunicorn command
CMD ["gunicorn", "--config", "gunicorn-cfg.py", "run:app"]
