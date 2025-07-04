FROM python:3.12

#Pip audit scans pyhton dependencies for vulnerabilities
RUN pip install --no-cache-dir pip-audit

#Health checks 
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:8080/health || exit 1

#Send container logs to AWS Cloudwatch

# Install CloudWatch Agent
RUN apt-get update && apt-get install -y awslogs aws-xray-daemon

# Set the log options
ENV AWS_LOGS_GROUP=Project-1-LG
ENV AWS_LOGS_STREAM=P1-Log-Stream
ENV AWS_REGION=us-east-1

# Set the log driver to awslogs
ENV LOG_DRIVER=awslogs

# Configure X-Ray
ENV XRAY_DAEMON_ENABLED=true
ENV XRAY_DAEMON_LOG_LEVEL=INFO
ENV XRAY_DAEMON_SERVICE_NAME=dispatcher

# Install CloudTrail
RUN pip install awscli

# Configure CloudTrail
ENV AWS_CLOUDTRAIL_REGION=us-east-1
ENV AWS_CLOUDTRAIL_BUCKET=my-bucket

# Create a CloudTrail trail
RUN aws cloudtrail create-trail --name my-trail --state-enabled --s3-bucket my-bucket

# Start the CloudTrail and Xray agents
CMD ["aws-xray-daemon", "-c", "/etc/aws-xray-daemon/xray-daemon.conf, aws-cloudtrail-agent", "-c", "/etc/aws-cloudtrail-agent/cloudtrail-agent.conf"]

#limit use of root user
RUN useradd -ms /bin/bash appuser
USER appuser
