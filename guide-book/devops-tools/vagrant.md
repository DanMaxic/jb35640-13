#VAGRANT
##Description:
###intro:
Vagrant is a tool for building and managing virtual machine environments in a single workflow. With an easy-to-use workflow and focus on automation, Vagrant lowers development environment setup time, increases production parity, and makes the "works on my machine" excuse a relic of the past. (taken from official site)

using this utility, enables us to create and use a complete virtual machine, with all needed tools with a push of a button. by using this tool, we are able to build and simulate situations and server easily and within a push of a button.

the fact that the tool is easy to learn and adopt, will help up to create closed labs and reproduce real semi-production enviroments.

the real engine that helps us to achive that, is what called "**box**".

a **vagrant box**, is actually a **base virtual machine image**, and vagrant uses those boxes to quickly clone them into an working virtual machine.
beside the boxes, vagrant is using a configuration file a"**Vagrantfile**" witch holds the configurations we want for the virtual machines.
see more info below for more information about it's components & tool workflow.

## Tool prerequisites
* OS : any
* software: virtual box (this is what we will use during the course): https://www.virtualbox.org/wiki/Downloads
** make sure to install all virtualbox components
## **websites\resources:**
- tool website: https://www.vagrantup.com/
- tool documentation: https://www.vagrantup.com/docs/index.html
- getting started manual: https://www.vagrantup.com/intro/getting-started/index.html
- tool CLI reference: https://www.vagrantup.com/docs/cli/
- list of 'boxes' available to use: https://app.vagrantup.com/boxes/search?provider=virtualbox

###notes:
- during the course we will use ubuntu or centos only machines

###configuration references:
- https://www.vagrantup.com/docs/vagrantfile/
- Vagrantfile reference: virtual machine settings: https://www.vagrantup.com/docs/vagrantfile/machine_settings.html
- provisioning settings: https://www.vagrantup.com/docs/provisioning/
  - Shell Provisioner: https://www.vagrantup.com/docs/provisioning/shell.html
  - File Provisioner: https://www.vagrantup.com/docs/provisioning/file.html
  - Docker Provisioner: https://www.vagrantup.com/docs/provisioning/docker.html
## **tool download:**
- download URI: https://www.vagrantup.com/downloads.html

**download only the 64bit**
## **Installation:**
**windows installation**
- next next next and finish 

**centos installation**
```bash
yum update -y
wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.rpm
yum install -y vagrant_2.2.4_x86_64.rpm
```

**ubuntu\debian installation**

```text
apt-get update -y
wget https://releases.hashicorp.com/vagrant/2.2.4/vagrant_2.2.4_x86_64.deb
dpkg -i vagrant_2.2.4_x86_64.deb -y
```

**Mac Installations:**
- open the dmg file and run the installer

## important notes:
- be extra carefull with the amount of resources you allocate to the virtual machine you are using.
- as a cation, use 1 cpu & 1024mb ram.
- try not to use the the GUI option, as a cation, set "virtualbox.gui = false"

## Tool work flow:
a basic workflow for vagrant based project is as following:
0. make sure vagrant and virtual box are installed properly.
1. create a project directory (may be part of a git repo)
2. create a **Vagrantfile** names "**Vagrantfile**"
3. apply vagrant file configurations (see example below:
    0. set the base box name name (the base virtualbox image that we will use) (g.e: config.vm.box = "ubuntu/trusty64")
    1. set the base box version (the version of the base image we will use) 
    2. set the virtual machine(s) params
    3. set the networking configurations (usually port forwarding ) 
    4. set the needed provisioners (shell\file\docker\other)
4. save the file
5. using terminal\power-shell console\CMD, navigate to the project directory
6. perform validation on your vagrant file, using the command: **vagrant validate**
7. if no error appear, proceed to bring up the machine you defined in the Vagrantfile. use the command **vagrant up**
8. stopping and starting the virtual machine:
    - to stop (halt) the machine use **vagrant halt**
    - to start the machine use **vagrant up**
    - note: the "halt" command shut the machine down, and forcing the virtual machine to perform cold boot.
9. suspend and resuming the virtual machine:
    - to suspend (pause) the machine use **vagrant suspend**
    - to start the machine use **vagrant resume**
    - note: A suspend effectively saves the exact point-in-time state of the machine, so that when you resume it later, it begins running immediately from that point, rather than doing a full boot.
10. connecting to the virtual machine to work:
    - to connect the machine defined on the vagrant file, using SSH, run the command **vagrant ssh**
    - to connect the machine defined on the vagrant file, using RDP, run the command **vagrant rdp** (windows only)
    - to connect the machine defined on the vagrant file, using POWER SHELL, run the command **vagrant powershell** (windows only)
11. in case you made a modifications in the **vagrantfile**, and you want to apply them, run **vagrant reload**
    - note: this is the equivalent of running a halt followed by an up.
12. if we wish to export the machine from virtualbox, use **vagrant package**
    - note: it will export the machine into package.box file
13. if we want to finish the work, and destroy the created machine, run **vagrant destroy**

### Vagrantfile examples:

simple vagrantfile for a single virtual machine running ubuntu:
```yaml
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  
  config.vm.hostname = 'myUbuntu'
  config.vm.provider 'virtualbox' do |virtualbox|
    virtualbox.linked_clone = true
    virtualbox.name = 'myUbubtu'
    virtualbox.gui = true
    virtualbox.memory =  3*1024
    virtualbox.cpus = 2
    virtualbox.customize ['modifyvm', :id, '--vram', 64]
    virtualbox.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    virtualbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.network "forwarded_port", guest: 8080, host: 8080, protocol: "tcp"

  config.vm.provision 'shell' do |initscript|
    initscript.path="user-data.sh"
  end
  config.vm.provision "file" do | filecopy|
    filecopy.source= "~/.gitconfig"
    filecopy.destination= ".gitconfig"
  end
end
```

## provitioning referance:

#### File Provisioner:
The Vagrant file provisioner allows you to upload a file or directory from the host machine to the guest machine.
##### attributes:
- inline (required, if path not defined)- the inline script to run 
- path (required)- the destination file in the virtual machine 
##### File Provisioner example:
**short syntax**
```yaml
  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
```
**note:** in the short syntax, the attributes' value are set by using ':'.

**long syntax**
```yaml
  config.vm.provision "file" do | filecopy|
      filecopy.source= "~/.gitconfig"
      filecopy.destination= ".gitconfig"
  end
```
**note:** in the long syntax, the attributes' value are set by using '=', and not ':' . 

#### shell Provisioner:
The Vagrant Shell provisioner allows you to upload and execute a script within the guest machine.
##### attributes:
- **inline** (required, if path not defined)- the inline script to run 
- **path** (required, , if inline not defined)- the path of the shell script to copy and excecute on the virtual machine
- args

##### shell Provisioner example:
**short syntax (path to script)**
```yaml
  config.vm.provision "shell", path: "script.sh"
```
**note:** in the short syntax, the attributes' value are set by using ':'.

**long syntax(path to script)**
```yaml
  config.vm.provision "shell" do | shell|
      shell.path = "script.sh"
  end
```
**note:** in the long syntax, the attributes' value are set by using '=', and not ':' . 

**short syntax (inline script)**
```yaml
  config.vm.provision "shell",inline: "echo Hello, World"
```
**note:** in the short syntax, the attributes' value are set by using ':'.

**long syntax(inline script)**
```yaml
  config.vm.provision "shell" do | shell|
      shell.inline = "echo Hello, World"
  end
```
**note:** in the long syntax, the attributes' value are set by using '=', and not ':' . 

**another syntax(multiline inline script)**
```yaml
$script = <<-SCRIPT
echo I am provisioning...
date > /etc/vagrant_provisioned_at
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: $script
```
