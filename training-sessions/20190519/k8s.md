##Subject:  Kubernetes Cluster Architecture

The Kubernetes architecture has two main roles: the master role and the worker role. In this lesson, we will take a look at what each role is and the individual components that make it run. We will even deploy a pod to see the components in action!
```bash
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
EOF

```
Official Kubernetes Documentation
Kubernetes Components Overview
API Server
Scheduler
Controller Manager
ectd Datastore
kubelet
kube-proxy
Container Runtime

##Subject 2: 
Every component in the Kubernetes system makes a request to the API server. The kubectl command line utility processes those API calls for us and allows us to format our request in a certain way. In this lesson, we will learn how Kubernetes accepts the instructions to run deployments and go through the YAML script that is used to tell the control plane what our environment should look like.
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```
Helpful Links
Spec and Status
API Versioning
Field Selectors

##Subject 3: Kubernetes Services and Network Primitives
Kubernetes services allow you to dynamically access a group of replica pods without having to keep track of which pods are moved, changed, or deleted. In this lesson, we will go through how to create a service and communicate from one pod to another.

The YAML to create the service and associate it with the label selector:
```
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  selector:
    app: nginx
```
To create the busybox pod to run commands from:
```
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    args:
    - sleep
    - "1000"
EOF
```
Helpful Links:
Kubernetes Services
The Role of kube-proxy