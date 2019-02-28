#Apache TOMCAT
##Description:
###intro:
Apache tomcat is a simple & free web server, and developed as part of the Apache foundation.
since the tomcat server has a very small footprint, and almost have no administrations cost, we may find in a lot of production enviroments.
tomcat is mainly running java based web applications, witch deployed into it as a **war** file (Web Application aRchive).

since there is a wide usage of that web server, it has large amount of vulnerabilities, so there is a good reason to hard the server against posible attacks  

   
## Tool prerequisites
* OS : any
* software: java (JRE\JDK)

**notes:**
- in PROD enviroment we will use JRE only and not JDK
- when installing it from repo manager (yum\apt\apt-get), the package comes with dedicated service (tomcat), and a dedicated user
- when running tomcat on windows, there is qa need to manually register it to system services using **sc** util
- when installing from packages (yum\apt), the following components not installed, this thig is a very good, since most server admins are by default are installing those, and causing huge security bridge :
    - docs - short documentation
    - examples - some example web sites
    - host-manager - web based management tool
    - manager - web based management tool & API 
- in case tomcat installed via it's binaries, there is a need to remove those web applications ASAP!

    

## **websites\resources:**
- tool website: http://tomcat.apache.org/
- tool documentation: https://tomcat.apache.org/tomcat-8.5-doc/index.html
- harding tomcat: https://www.owasp.org/index.php/Securing_tomcat

###notes:
- during the course we will use ubuntu or centos only machines

###configuration references:
- harding tomcat: https://www.owasp.org/index.php/Securing_tomcat
- connectors definitions

## **tool download:**
- download URI: https://tomcat.apache.org/download-90.cgi

**download only the 64bit**
## **Installation:**
**windows installation**
- next next next and finish 

**centos installation**
```bash
yum update -y && sudo yum install tomcat -y
```

**ubuntu\debian installation**

```text
sudo apt-get install tomcat8 -y
```

**vagrant example Installations:**
```yaml
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.hostname = 'tomcat'

  config.vm.provider 'virtualbox' do |virtualbox|
    virtualbox.linked_clone = true
    virtualbox.name = 'tomcat'
    virtualbox.memory =  1024
    virtualbox.cpus = 1
    virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    virtualbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.network "forwarded_port", guest: 8080, host: 8080, protocol: "tcp"

  config.vm.provision "shell" do | filecopy|
      filecopy.inline ="apt-get update -y && apt-get install tomcat7 -y"
  end

end
```

##important notes:
- main config file called **server.xml** located at /etc/tomcat* (**/etc/tomcat/server.xml**)
- in case package installation placed all configs under versioned folder (such as /etc/tomcat7), you need to crease a symbolic link to /etc/tomcat 
    - use following command: **ln -s /etc/tomcat7 /etc/tomcat**
    - this way you make sure that the tomcat server are managed always with the same way
- **please note, the file is written as XML**
    - meaning some parts in the file remarked (noted) with XML remark (<!-- and -->)

## tomcat port configurations:
- listening port in tomcat configured in the **Connector** object as following
```xml
<Connector executor="tomcatThreadPool"
 port="8080" protocol="HTTP/1.1"
 connectionTimeout="20000"
 redirectPort="8443" />
```
- in order to change the port, you need to modify the value of the port attribute .
- if you deciding to replace the port using sed command similar to following example, it may not work, until service restart:
```bash
PORT=9090
sed -i "s|.*\<Connector port=\"8080\" protocol=\"HTTP\/1.1\"*|\<Connector port=\"${PORT}\" protocol=\"HTTP/1.1\"|g" /etc/tomcat/server.xml
```


