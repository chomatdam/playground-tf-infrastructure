#!/bin/bash
set -e
# Send the log output from this script to user-data.log, syslog, and the console (https://alestic.com/2010/12/ec2-user-data-output)
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Shell variables
CONSUL_VERSION="${consul_version}"
CONSUL_CLUSTER_TAG_KEY="${consul_cluster_tag_key}"
CONSUL_CLUSTER_TAG_VALUE="${consul_cluster_tag_value}"
VAULT_VERSION="${vault_version}"


# Update the packages.
sudo yum update -y

# Install Docker, add ec2-user, start Docker and ensure startup on restart
yum install -y docker
usermod -a -G docker ec2-user
service docker start
chkconfig docker on

#TODO: create and push certificates
#readonly VAULT_TLS_CERT_FILE="/opt/vault/tls/vault.crt.pem"
#readonly VAULT_TLS_KEY_FILE="/opt/vault/tls/vault.key.pem"

# Local IP
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "Instance IP is: $IP"

# Start the Consul client.
docker run -d --net=host \
    --name=consul-client \
    consul:$CONSUL_VERSION agent \
    -bind=$IP \
    -retry-join="provider=aws tag_key=$CONSUL_CLUSTER_TAG_KEY tag_value=$CONSUL_CLUSTER_TAG_VALUE"

# Start the Vault server.
sed -i "s/\bEC2_VAULT_IP_ADDRESS\b/$IP/g" /tmp/vault/config.hcl
docker run \
    --name=vault-server \
    --net=host \
    --cap-add=IPC_LOCK \
    --volume /tmp/vault:/vault/file \
    vault:$VAULT_VERSION \
    server \
    -config=/vault/file/config.hcl


# When you ssh to one of the instances in the vault cluster and initialize the server
# You will notice it will now boot unsealed
# /opt/vault/bin/vault operator init
# /opt/vault/bin/vault status
#
# If the enterprise license isn't applied, it will however reseal after 30 minutes
# This is how you apply the license, please note that the VAULT_TOKEN environment
# variable needs to be set with the root token obtained when you initialized the server
# /opt/vault/bin/vault write /sys/license "text=<vault_enterprise_license_key>"
