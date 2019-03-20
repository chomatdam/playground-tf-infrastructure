#!/usr/bin/env bash
EBS_PATH=${path}
EBS_SYSTEM_PATH=`readlink -f $EBS_PATH`

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

if [[ ! $(sudo file -s $EBS_SYSTEM_PATH) == *filesystem* ]]; then
  # Mount volume
  echo "creating filesystem on volume $EBS_SYSTEM_PATH..."
  mkfs -t xfs $EBS_SYSTEM_PATH
fi

MOUNT_POINT=/data
if [[ ! -d $MOUNT_POINT ]]; then
    echo "mounting volume $EBS_SYSTEM_PATH  at the directory $MOUNT_POINT"
    mkdir $MOUNT_POINT
    mount $EBS_SYSTEM_PATH $MOUNT_POINT
fi

su ec2-user
docker run -d --name splunk -v /data:/opt/splunk -p 8000:8000  -e 'SPLUNK_START_ARGS=--accept-license' -e 'SPLUNK_PASSWORD=admindefault' splunk/splunk:latest
