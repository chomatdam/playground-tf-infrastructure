#!/usr/bin/env bash

OWNER=${owner}
S3_BUCKET=${bucket_name}
OPEN_VPN_PATH=/etc/openvpn
EASY_RSA_PATH=$OPEN_VPN_PATH/easy-rsa
EASY_RSA_VERSION=3.0.6

set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Exit on failure enabled and start logging..."

sudo su
yum update -y
amazon-linux-extras install epel -y
yum-config-manager --enable epel
yum repolist | grep epel
yum -y install openvpn

wget -v https://github.com/OpenVPN/easy-rsa/releases/download/v$EASY_RSA_VERSION/EasyRSA-unix-v$EASY_RSA_VERSION.tgz -P $OPEN_VPN_PATH
mkdir $EASY_RSA_PATH
tar -xzvf $OPEN_VPN_PATH/*.tgz -C $EASY_RSA_PATH --strip 1

$EASY_RSA_PATH/easyrsa init-pki
$EASY_RSA_PATH/easyrsa --batch --req-cn="$OWNER Root CA" build-ca nopass
$EASY_RSA_PATH/easyrsa gen-dh

$EASY_RSA_PATH/easyrsa build-server-full server nopass  # Used by server.conf
$EASY_RSA_PATH/easyrsa build-client-full client nopass

aws s3 sync $$EASY_RSA_PATH/pki s3://$S3_BUCKET --exclude "*" --include "*.crt" --include "*.key"

echo 1 | tee /proc/sys/net/ipv4/ip_forward
sysctl -p

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

# New VPN user certificate
#./easyrsa gen-req --req-cn=${lambda_user_req_input} client-req nopass
# Revoke VPN user certificate
#./easyrsa revoke ${CERT_NAME}
#./easyrsa gen-crl

systemctl start openvpn@server.service  # @server <-> server.conf
systemctl status openvpn@server.service
