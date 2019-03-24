#!/usr/bin/env bash
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

su ec2-user
docker run \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --volume=/var/lib/drone:/data \
  --env=DRONE_GITHUB_SERVER=https://github.com \
  --env=DRONE_GITHUB_CLIENT_ID=${github_oauth_app_client_id} \
  --env=DRONE_GITHUB_CLIENT_SECRET=${github_oauth_app_client_secret} \
  --env=DRONE_USER_FILTER=${github_organization} \
  --env=DRONE_RPC_SECRET=${drone_rpc_secret} \
  --env=DRONE_SERVER_HOST=${domain_name} \
  --env=DRONE_SERVER_PROTO=https \
  --env=DRONE_TLS_AUTOCERT=true \
  --env=DRONE_S3_BUCKET=${s3_bucket} \
  --env=DRONE_DATABASE_DRIVER=postgres \
  --env=DRONE_DATABASE_DATASOURCE=postgres://${postgres_username}:${postgres_password}@${postgres_endpoint}/${postgres_dbname}?sslmode=disable \
  --publish=80:80 \
  --publish=443:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  drone/drone:1


#   --env=DRONE_AGENTS_ENABLED=true   -> once you have workers ready to connect