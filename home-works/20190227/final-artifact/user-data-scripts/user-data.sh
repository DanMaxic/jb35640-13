#!/bin/bash
#   DEPLOYMENT SCRIPT FOR TF MODULE

apt-get update -y && apt-get install tomcat7 -y
ln -s /etc/tomcat* /etc/tomcat