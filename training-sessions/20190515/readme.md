# class training: Ansible Essentials

Today’s Agenda
Arrivals, Introductions

Workshop Setup

* Exercise 1.1 - Ad-Hoc Commands
* Exercise 1.2 - Writing Your First Playbook
* Exercise 1.3 - Running Your First Playbook
* Exercise 1.4 - Using Variables, loops, and handlers
* Exercise 1.5 - Running the apache-basic-playbook
* Exercise 1.6 - Roles: Making your playbooks reusable
* Resources, Wrap Up

## Bring up the environment
  run the vargant project located at: **resources/vagrants/ansible-lab**
  * Validate lab is up and running 
## Exercise 1.1 - Running Ad-hoc commands
**For our first exercise, we are going to run some ad-hoc commands to help you get a feel for how Ansible works. Ansible Ad-Hoc commands enable you to perform tasks on remote nodes without having to write a playbook. They are very useful when you simply need to do one or two things quickly and often, to many remote nodes.**

Like many Linux commands, ansible allows for long-form options as well as short-form. For example:

```
ansible web --module-name ping
```
is the same as running
```
ansible web -m ping
```
We are going to be using the short-form options throughout this workshop

**Step 1: Let’s start with something really basic - pinging a host. The ping module makes sure our web hosts are responsive.**

```
ansible web -m ping
```

**Step 2: Now let’s see how we can run a good ol' fashioned Linux command and format the output using the command module.**

```
ansible web -m command -a "uptime" -o
```
**Step 3: Take a look at your web node’s configuration. The setup module displays ansible facts (and a lot of them) about an endpoint.**

```
ansible web -m setup
```

**Step 4: Now, let’s install Apache using the yum module**

```
ansible web -m yum -a "name=httpd state=present" -b
```
**Step 5: OK, Apache is installed now so let’s start it up using the service module**

```
ansible web -m service -a "name=httpd state=started" -b
```
**Step 6: Finally, let’s clean up after ourselves. First, stop the httpd service**

```
ansible web -m service -a "name=httpd state=stopped" -b
```
**Step 7: Next, remove the Apache package**

```
ansible web -m yum -a "name=httpd state=absent" -b
```

## Exercise 1.2 - Writing Your First playbook
http://ansible.redhatgov.io/standard/core/exercise1.2.html

## Exercise 1.3 - Running Your Playbook
http://ansible.redhatgov.io/standard/core/exercise1.3.html

## Exercise 1.4 - Using Variables, loops, and handlers
http://ansible.redhatgov.io/standard/core/exercise1.4.html

## Exercise 1.5 - Running the apache-basic-playbook
http://ansible.redhatgov.io/standard/core/exercise1.5.html


