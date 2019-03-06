#!/usr/bin/env bash


function main(){
  read -p "please choose a desired port: "  PORT
  sed -i "s|.*\<Connector port=\"[0-66666666]*\" protocol=\"HTTP\/1.1\"*|\<Connector port=\"${PORT}\" protocol=\"HTTP/1.1\"|g" /etc/tomcat/server.xml
  echo "the port successfully changed to $PORT!"
  sudo service tomcat7 restart
  echo "done!"
}
main