# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP run.py
ENV DEBUG True

# Variables will be taken from the environment or from the .env file.
ENV DB_ENGINE="" 
ENV DB_USERNAME=""
ENV DB_PASS=""
ENV DB_HOST=""
ENV DB_PORT=""
ENV DB_NAME=""


# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
    gcc \
    python3-dev \
    libmariadb-dev \
    mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install mysql-connector-python

# Copy application code
COPY . .

# Install python-dotenv
RUN pip install python-dotenv

RUN flask db init
RUN flask db migrate -m "Initial migration"
RUN flask db upgrade

# Run Flask database migration commands separately
#RUN dotenv run flask db init && echo "DB init completed"
#RUN dotenv run flask db migrate && echo "DB migrate completed"
#RUN dotenv run flask db upgrade && echo "DB upgrade completed"


# Gunicorn command
CMD ["gunicorn", "--config", "gunicorn-cfg.py", "run:app"]
