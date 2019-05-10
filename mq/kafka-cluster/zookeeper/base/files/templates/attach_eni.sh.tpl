#!/bin/bash
# --Required AWS permissions for this script are: AttachNetworkInterface DescribeNetworkInterfaces
# Terraform
ZK_NODE_NUMBER=${zk_node_number}
# AWS Metadata
REGION=`curl -s 169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//'`
aws configure set region $REGION
INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
MAC_ADDRESS=`curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ | sed 's/.$//'`
SUBNET_ID=`curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC_ADDRESS/subnet-id`
ENI_ID=`aws ec2 describe-network-interfaces \
--filters "Name=tag:Service,Values=Zookeeper" "Name=tag:Node,Values=$ZK_NODE_NUMBER" "Name=subnet-id,Values=$SUBNET_ID" "Name=status,Values=available" \
--query "NetworkInterfaces[0].NetworkInterfaceId" \
--output text`

aws ec2 attach-network-interface --network-interface-id $ENI_ID --instance-id $INSTANCE_ID --device-index 1