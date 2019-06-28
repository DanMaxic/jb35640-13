#!/usr/bin/env bash
#!/bin/bash

##PARAMS
JENKINS_REPO_URI="jenkins-2.150.2-1.1"
NEXUS_REPO_URI="https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.0.2-02-unix.tar.gz"
REMOTE_SSH_PORT="9090"
SSH_USERNAME="meme"
SSH_PSSWORD="Letitbe123!"
## END PARAMS

function installPreReq(){
    echo "±±±±±±±±±±±±±>installPreReq"


    wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
    sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
    yum install -y apache-maven
    yum update -y && yum install -y yum-utils git jq aws-cli docker bind-utils nano apache-maven java java-1.8.0-openjdk-devel wget unzip bash-completion
}

function installKubectl(){
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mv ./kubectl /usr/bin/kubectl
  echo "source <(kubectl completion bash)" >> ~/.bashrc

}

function installDocker(){
  yum install -y docker
  systemctl enable docker
  systemctl start docker
}

function installJenkins(){
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  echo "±±±±±±±±±±±±±>install jenkins"
  #yum install -y https://prodjenkinsreleases.blob.core.windows.net/redhat-stable/${JENKINS_REPO_URI}.noarch.rpm java
  yum install jenkins -y

  systemctl enable jenkins
  systemctl start jenkins

}

function installAnsible(){
  yum install ansible
}

function installMaven(){
  wget https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -P /tmp
  sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt
  sudo ln -s /opt/apache-maven-3.6.0 /opt/maven
  sudo ln -s /opt/maven/bin/mvn /usr/bin/mvn
  mvn --version
}


function praperMVN() {
    git clone https://github.com/zivkashtan/course.git
    cd course/
    mvn package
    cd ../
    rm -rf course/
}
function installNexusArtifactory(){
  mkdir /app && cd /app
  wget $NEXUS_REPO_URI
  tar -xvf nexus-*.tar.gz
  rm -f nexus-*.tar.gz
  mv nexus-* nexus
  adduser nexus
  chown -R nexus:nexus /app/nexus
  echo -e "\nrun_as_user=\"nexus\"" >> /app/nexus/bin/nexus.rc
  cat << EOF > /etc/ecs/ecs.config
-Xms1200M
-Xmx1200M
-XX:+UnlockDiagnosticVMOptions
-XX:+UnsyncloadClass
-Djava.net.preferIPv4Stack=truer
-Dkaraf.home=.
-Dkaraf.base=.
-Dkaraf.etc=etc
-Djava.util.logging.config.file=etc/java.util.logging.properties
-Dkaraf.data=/nexus/nexus-data
-Djava.io.tmpdir=data/tmp
-Dkaraf.startLocalConsole=false
EOF
  sudo ln -s /app/nexus/bin/nexus /etc/init.d/nexus
  chkconfig --add nexus
  chkconfig --levels 345 nexus on
  systemctl enable nexus
  systemctl start nexus
}

function installWetty(){
  yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum groupinstall "Development Tools" -y
  sudo yum install -y nodejs npm --enablerepo=epel
  npm install wetty -g
  groupadd wetty_users
  useradd wetty -G wetty_users

  sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  systemctl restart sshd
  systemctl enable wetty.service
  systemctl start wetty.service
}

function configureLogins(){

    groupadd remote_users
    echo "remote_users    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers
    echo "${SSH_USERNAME}    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers
    useradd ${SSH_USERNAME} -G remote_users
    echo "${SSH_PSSWORD}" | sudo passwd ${SSH_USERNAME} --stdin
    systemctl restart sshd

}


function main(){
  installPreReq
  installMaven
  installAnsible

  installDocker
  installJenkins
  installNexusArtifactory
  installWetty

  configureLogins
}
main
