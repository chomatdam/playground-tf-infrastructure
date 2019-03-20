#!/usr/bin/env bash
SPLUNK_HOME=/opt/splunk

wget -O splunk.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.2.5&product=splunk&filename=splunk-7.2.5-088f49762779-linux-2.6-x86_64.rpm&wget=true'
rpm -i splunk.rpm

cat >> /etc/init.d <<EOL
./splunk start --accept-license
./splunk enable boot-start
EOL

cat >> $SPLUNK_HOME/etc/system/local/user-seed.conf <<EOL
[user_info]
USERNAME = admin
PASSWORD = admindefault
EOL

splunk start --accept-license --no-prompt

IP=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
echo http://$IP:8000