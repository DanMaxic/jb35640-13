


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
##Lecture: Kubernetes Services and Network Primitives

Kubernetes services allow you to dynamically access a group of replica pods without having to keep track of which pods are moved, changed, or deleted. In this lesson, we will go through how to create a service and communicate from one pod to another.
 
 The YAML to create the service and associate it with the label selector:
 ```yaml
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
```bash
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
