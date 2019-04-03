#!/bin/bash
REMOTE_SSH_PORT="2020"

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
  service sshd restart
  echo "wetty    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers
  systemctl enable wetty.service
  systemctl start wetty.service
}

function main() {
    #installWetty
    echo "skip"
}

main