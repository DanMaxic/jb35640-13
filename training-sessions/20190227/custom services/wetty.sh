#!/bin/bash

##PARAMS
REMOTE_SSH_PORT="9090"
## END PARAMS

function installPreReq(){
    echo "±±±±±±±±±±±±±>installPreReq"


    wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
    sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
    yum install -y apache-maven
    yum update -y && yum install -y yum-utils git jq aws-cli docker bind-utils nano apache-maven java
}




function installWetty(){
  yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum groupinstall "Development Tools" -y
  sudo yum install -y nodejs npm --enablerepo=epel
  npm install wetty -g
  groupadd wetty_users
  useradd wetty -G wetty_users
  cat << EOF > /etc/systemd/system/wetty.service
[Unit]
Description=wetty remote ssh web
After=network.target

[Service]
ExecStart=/usr/bin/node /usr/lib/node_modules/wetty/bin/wetty.js -p ${REMOTE_SSH_PORT}
#WorkingDirectory=/opt/nodeserver
Restart=always
 RestartSec=10
 # Output to syslog
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=nodejs-example
User=wetty
Group=wetty_users

[Install]
WantedBy=multi-user.target
EOF
  sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  systemctl restart sshd
  systemctl enable wetty.service
  systemctl start wetty.service
}




function main(){
  installPreReq
  installWetty
}
main
