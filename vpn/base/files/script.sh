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
#mkdir $EASY_RSA_PATH  # not needed with Terraform because Cloud-init is creating the 'vars' file in this directory
tar -xzvf $OPEN_VPN_PATH/*.tgz -C $EASY_RSA_PATH --strip 1

cd $EASY_RSA_PATH
./easyrsa init-pki
./easyrsa --batch --req-cn="$OWNER Root CA" build-ca nopass
./easyrsa gen-dh

./easyrsa build-server-full server nopass  # Used by server.conf
./easyrsa build-client-full client nopass

openvpn --genkey --secret $OPEN_VPN_PATH/ta.key


aws s3 sync $OPEN_VPN_PATH s3://$S3_BUCKET --exclude "*" --include "*.crt" --include "*.key"

echo 1 | tee /proc/sys/net/ipv4/ip_forward
sysctl -p

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

systemctl start openvpn@server.service  # @server <-> server.conf
systemctl enable openvpn@server.service
systemctl status openvpn@server.service
