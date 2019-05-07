#!/usr/bin/env bash
DOCKER_VERSION=1.24.0

set -e
# Send the log output from this script to user-data.log, syslog, and the console (https://alestic.com/2010/12/ec2-user-data-output)
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Exit on failure enabled and start logging..."

sudo su
# Update the packages.
yum update -y
# Install Docker and allow ec2-user to connect to the daemon socket
yum install -y docker
usermod -a -G docker ec2-user
service docker start

curl -L https://github.com/docker/compose/releases/download/$DOCKER_VERSION/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose -f /tmp/docker-compose.yml up