#!/bin/bash
# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

# A few variables we will refer to later...
ASG_NAME="${asgname}"
REGION="${region}"
EXPECTED_SIZE="${size}"
CONSUL_VERSION="${consul_version}"
TAG_KEY="${node_tag_key}"
TAG_VALUE="${node_tag_value}"

# Update the packages.
sudo yum update -y

# Install Docker, add ec2-user, start Docker and ensure startup on restart
yum install -y docker
usermod -a -G docker ec2-user
service docker start
chkconfig docker on

IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "Instance IP is: $IP"

# Start the Consul server.
docker run -d --net=host \
    --name=consul \
    consul:$CONSUL_VERSION agent -server -ui \
    -bind=$IP \
    -client="0.0.0.0" \
    -bootstrap-expect="$EXPECTED_SIZE" \
    -retry-join="provider=aws tag_key=$TAG_KEY tag_value=$TAG_VALUE"
