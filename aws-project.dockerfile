# Use an official Python runtime as a parent image (Use Brave)
FROM python:3.12
# FROM mcr.microsoft.com/playwright:v1.40.0-jammy

ENV PYTHONDONTWRITEBYTECODE=1
# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /

# Install system dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the current directory contents into the container at 
COPY . /
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -U pip \
    && pip install --no-cache-dir -r requirements.txt

# Remove git if it is installed (it's not needed, and has a critical vulnerability reported from AWS inspector)
RUN apt-get remove -y git \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Run app.py when the container launches
ENTRYPOINT ["entrypoint.sh"]


#Pip audit scans pyhton dependencies for vulnerabilities
RUN pip install --no-cache-dir pip-audit

#Health checks 
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:8080/health || exit 1

#Send container logs to AWS Cloudwatch

# Install CloudWatch Agent (official agent, recommended)
[general]
state_file = /var/awslogs/state/agent-state

# Set the log driver to awslogs
ENV LOG_DRIVER=awslogs

[/var/log/syslog]
file = /var/log/syslog
log_group_name = Project-log-group
log_stream_name = Project-log-stream
datetime_format = %b %d %H:%M:%S

# Configure CloudTrail 
ENV AWS_CLOUDTRAIL_REGION=us-east-2
ENV AWS_CLOUDTRAIL_BUCKET=project-bucket-1996

# Create a CloudTrail trail
RUN aws cloudtrail create-trail --name my-trail --state-enabled --project-bucket-1996

#Install Datadog agent



#limit use of root user
RUN useradd -ms /bin/bash appuser
USER appuser
