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
ansible all -i inventory -m ping
```

We are going to be using the short-form options throughout this workshop

**Step 1: Let’s start with something really basic - pinging a host. The ping module makes sure our web hosts are responsive.**

```
ansible web -m ping
```

**Step 2: Now let’s see how we can run a good ol' fashioned Linux command and format the output using the command module.**


```
ansible all -i inventory -m ping -m command -a "uptime" -o
```
**Step 3: Take a look at your web node’s configuration. The setup module displays ansible facts (and a lot of them) about an endpoint.**

```
ansible all -i inventory -m setup
```

**Step 4: Now, let’s install Apache using the yum module**

```
ansible all -i inventory -m yum -a "name=httpd state=present" -b
```
**Step 5: OK, Apache is installed now so let’s start it up using the service module**

```
ansible web -i inventory -m service -a "name=httpd state=started" -b
```
**Step 6: Finally, let’s clean up after ourselves. First, stop the httpd service**

```
ansible web -i inventory -m service -a "name=httpd state=stopped" -b
```
**Step 7: Next, remove the Apache package**

```
ansible web -i inventory -m yum -a "name=httpd state=absent" -b
```

## Exercise 1.2 - Writing Your First playbook

### Section 1 - Creating a Directory Structure and Files for your Playbook
#### Step 1: Create a directory called apache_basic in your home directory and change directories into it
```bash
 mkdir ~/apache_basic
 cd ~/apache_basic
``` 
 
#### Step 2: Define your inventory. Inventories are crucial to Ansible as they define remote machines on which you wish to run your playbook(s). Use vi or vim to create a file called hosts. Then, add the appropriate definitions which can be viewed in ~/lightbulb/lessons/lab_inventory/{{studentX}}-instances.txt. (And yes, I suppose you could copy the file, but we’d rather you type it in so you can become familiar with the syntax)
```bash
[web]
node-1 ansible_host=<IP Address of your node-1>
node-2 ansible_host=<IP Address of your node-2>
```
#### Step 3: Use vi or vim to create a file called install_apache.yml
## Section 2 - Defining Your Play

Now that you are editing install_apache.yml, let’s begin by defining the play and then understanding what each line accomplishes
```bash
---
- hosts: web
  name: Install the apache web service
  become: yes
  ```
* --- Defines the beginning of YAML
* hosts: web Defines the host group in your inventory on which this play will run against
* name: Install the apache web service This describes our play
* become: yes Enables user privilege escalation. The default is sudo, but su, pbrun, and several others are also supported.

### Section 3: Adding Tasks to Your Play

Now that we’ve defined your play, let’s add some tasks to get some things done. Align (vertically) the t in task with the b become. 
Yes, it does actually matter. In fact, you should make sure all of your playbook statements are aligned in the way shown here.
If you want to see the entire playbook for reference, skip to the bottom of this exercise.
```yaml
tasks:
 - name: install apache
   yum:
     name: httpd
     state: present

 - name: start httpd
   service:
     name: httpd
     state: started
```
tasks: This denotes that one or more tasks are about to be defined

- name: Each task requires a name which will print to standard output when you run your playbook. Therefore, give your tasks a name that is short, sweet, and to the point
```yaml
yum:
  name: httpd
  state: present
```
These three lines are calling the Ansible module yum to install httpd. Click here to see all options for the yum module.
```yaml
service:
  name: httpd
  state: started
```
The next few lines are using the ansible module service to start the httpd service. The service module is the preferred way of controlling services on remote hosts. Click here to learn more about the service module.

Section 4: Review

Now that you’ve completed writing your playbook, it would be a shame not to keep it.

Use the write/quit method in vi or vim to save your playbook, i.e. Esc :wq!

And that should do it. You should now have a fully written playbook called install_apache.yml. You are ready to automate!

http://ansible.redhatgov.io/standard/core/exercise1.2.html

## Exercise 1.3 - Running Your Playbook
http://ansible.redhatgov.io/standard/core/exercise1.3.html

## Exercise 1.4 - Using Variables, loops, and handlers
http://ansible.redhatgov.io/standard/core/exercise1.4.html

## Exercise 1.5 - Running the apache-basic-playbook
http://ansible.redhatgov.io/standard/core/exercise1.5.html


