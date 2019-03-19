#!/bin/bash
set -e
# Send the log output from this script to user-data.log, syslog, and the console (https://alestic.com/2010/12/ec2-user-data-output)
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Shell variables
CONSUL_VERSION="${consul_version}"
VAULT_VERSION="${vault_version}"

# Update the packages.
sudo yum update -y

# Install Docker, add ec2-user, start Docker and ensure startup on restart
yum install -y docker
usermod -a -G docker ec2-user
service docker start
chkconfig docker on

# TODO: create and push certificates !
readonly VAULT_TLS_CERT_FILE="/opt/vault/tls/vault.crt.pem"
readonly VAULT_TLS_KEY_FILE="/opt/vault/tls/vault.key.pem"
readonly VAULT_CONFIG="/opt/vault/config.hcl"

# Start the Consul server.
docker run -d --net=host \
    --name=consul-client \
    consul:$CONSUL_VERSION agent \
    --client \
    --cluster-tag-key "${consul_cluster_tag_key}" \
    --cluster-tag-value "${consul_cluster_tag_value}"

# TODO: VAULT_CONFIG to upload - check options available, enable and mount volume for certificates or disable TLS
docker run --cap-add=IPC_LOCK \
        --name=vault-server \
        -e 'VAULT_LOCAL_CONFIG={"backend": {"file": {"path": "$$VAULT_CONFIG"}}, "default_lease_ttl": "168h", "max_lease_ttl": "720h"}' \
        vault:$VAULT_VERSION \
        server \
        --enable-auto-unseal \
        --auto-unseal-kms-key-id "${kms_key_id}" \
        --auto-unseal-kms-key-region "${aws_region}" \
        --tls-cert-file "$VAULT_TLS_CERT_FILE" \
        --tls-key-file "$VAULT_TLS_KEY_FILE"


# When you ssh to one of the instances in the vault cluster and initialize the server
# You will notice it will now boot unsealed
# /opt/vault/bin/vault operator init
# /opt/vault/bin/vault status
#
# If the enterprise license isn't applied, it will however reseal after 30 minutes
# This is how you apply the license, please note that the VAULT_TOKEN environment
# variable needs to be set with the root token obtained when you initialized the server
# /opt/vault/bin/vault write /sys/license "text=<vault_enterprise_license_key>"
