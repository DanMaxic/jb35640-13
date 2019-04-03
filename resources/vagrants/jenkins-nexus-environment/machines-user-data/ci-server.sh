#!/bin/bash

##PARAMS
JENKINS_REPO_URI="jenkins-2.150.2-1.1"
## END PARAMS

function installPreReq(){
    echo "±±±±±±±±±±±±±>installPreReq"
    yum update -y
    yum install -y yum-utils git jq aws-cli docker bind-utils nano java-1.8.0-openjdk-devel wget unzip bash-completion
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

function installTerraform(){
  wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip
  unzip terraform_*
  mv terraform /usr/bin/
  rm -rf terraform_*

}
function installAnsible(){
  yum install -y  ansible
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


function main(){
  installPreReq
  installMaven
#  installAnsible
#  installDocker
#  installKubectl
#  installTerraform
  installJenkins
  praperMVN
}
main
