# HOME WORK #11
## Introduction & details
- given on: Sun, May 26, 2019
- delivery date: Sun, June 2nd, 2019
     
  
## here we will practice translate a "free-style" job into pipeline project
# HOME WORK #3
## Introduction & details
- given on: Wed, Mar 17, 2019
- delivery date: Sun, Mar 24, 2019
- delivery method: 
  - All tasks should be delivelabe in the homework-template.docx template
- item(s) to deliver: 
  - Please use the word\open-office template in order to deliver the homework (homework.docx\homework.odt).
  - short diagram, describes the infrastructure created by you. use draw.io to generate an image of that (https://draw.io) 
- *DONOT FORGET*: please write your full name, and your ID 
- some guide lines:
  - scripting:
    - keep proper code indentation(s)
    - keep proper code styling 
    - more info you may find here: https://google.github.io/styleguide/shell.xml
    
### Homework subjects:
- vagrant: building whole CI\CD environment including: Jenkins server, Nexus server, tomcat server, docker server and k8s minikube server
- Linux scripting 
- Jenkins: Writing Jenkins file pipeline 
- docker: docker build, running commands
- k8s: perform simple deployments, minikube

### Homework Tasks:
- **Task #1: prepare the CI environment(20%)**
  - the CI\CD environment should be build from the following 3 servers:
    - Jenkins & Nexus server
    - tomcat & docker server
    - k8s (minikube) server
  - note the following:
    - most components are already exist on "resources" directory, make shure to use the most of that, before searching in google
    - note that there some operations on servers may need to make manually after the provisioning the servers using vagrant. operations such as jenkins plugins instalations, jenkins global tools configurations and more)
    - make sure to create a diagram (using draw.io) before start to write the SLN.
  - specs:
    - each server will have 1 gb RAM, 1 vcpu, all are connected to internal network
    - Jenkins & nexus server:
      - jenkins:
        - port opearting: 8080
        - don't forget the following plugins: (pipeline, blue ocean, git, maven, Pipeline Utility Steps, Ansible, Nexus  and more )
        - don't forget to configure the global tool configuration
        - don't forget to configure the credentials
      - Nexus:
        - port for regular operating: 8081
        - port for the docker hosted:8083
        - don't forget the realms configs for docker on the nexus
      - Docker: 
        - don't forget the config on the /etc/docker/daemon.json to enable non SSL docker registry 
        
    - tomcat & docker server:
      - tomcat: 
        - port: 8080
        - make sure autodeployment war flag is enabled
      - docker: 
        - don't forget the config on the /etc/docker/daemon.json to enable non SSL docker registry
        - don't forget the config on the /etc/docker/daemon.json to enable listening on remote TCP port
    
- **Task #2: Jenkins Pipeline(80%)**
  - Sub-task 2.1: **Create a basic jenkins pipeline** 
    - use the src git repo: 
    - start with the regular 3 blocks (prepare, build, release)
    - the result of running the CI script will be:
      - on the "release" block, both the WAR file and the docker image will be hosted on the Nexus server
      - feel free to use the templates in the "resources" directory
      - paste the image of proof in the .doc template as evidance
       
  - Sub-task 2.2: **customizing the pipeline**
    - add to the pipeline as following:
      - new 3 build parameters:
        - **buildMode**: choice parameter: dev\qa, 
          - dev will enable ignoring failed unit-tests
          - qa wont ignore failed unit-tests.
        - **artifactName**: will represent the final artifact name appear on the nexus server (both for docker and war file), default value "pract11"
        - **depTarget**: will represent the deployment targets, choices are: **ansible, Docker, k8s**
        
  - Sub-task 2.3: **customizing the buildNumber**
    - in the "prepare" block of the CI, read the version from the pom.xml, and to that attach the current build number.
    - make sure to use variables inside of that.
    - make sure the artifacts are maked properly in the Nexus server.
    - attach picture to the .doc file as proof
    
  - Sub-task 2.4: **implement the functions of the "buildMode, and the artifactName" prams**
    - implement the functions of the  "buildMode, and the artifactName" build parameters you added into your Jenkinsfile on step 2.2
    
  - Sub-task 2.5: **handling 
  **
    - desc: we will get familer with the make\makefile build framework
    - please see task2.md
    - the output will be a bash script, **Makefile**
- **Task #3: designing the DevOps infrastructure**
  - desc: we will perform step by step a MSbuild build (for .NET applications)
  - please see task3.md
  - the output will be following files:
  
