

#k8s class practice

##minikube installation


###Linux Installation
```bash
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
```

###Windows instalattion
```bash

```

###starting minikube
```bash
minikube start
```
minikube start


##testing

###Create an echo server deployment

```bash
kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.10 --port=8080
```

```bash
kubectl expose deployment hello-minikube --type=NodePort
```

##k8k ops
###practice 1: Create a Deployment
A Kubernetes Pod is a group of one or more Containers, tied together for the purposes of administration and networking. The Pod in this tutorial has only one Container. A Kubernetes Deployment checks on the health of your Pod and restarts the Pod’s Container if it terminates. Deployments are the recommended way to manage the creation and scaling of Pods.

  1. Use the kubectl create command to create a Deployment that manages a Pod. The Pod runs a Container based on the provided Docker image.
  ```bash
kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
```
 2. View the Deployment:

```bash
kubectl get deployments
```

Output:
```bash
NAME         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-node   1         1         1            1           1m

```
3. View the Pod:

```kubectl get pods```

Output:
```bash
NAME                          READY     STATUS    RESTARTS   AGE
hello-node-5f76cf6ccf-br9b5   1/1       Running   0          1m
```
4. View cluster events:

```
kubectl get events
```
5. View the kubectl configuration:

```
kubectl config view
```

###practice 2: Create a Service
By default, the Pod is only accessible by its internal IP address within the Kubernetes cluster. To make the hello-node Container accessible from outside the Kubernetes virtual network, you have to expose the Pod as a Kubernetes Service.

1. Expose the Pod to the public internet using the kubectl expose command:

```kubectl expose deployment hello-node --type=LoadBalancer --port=8080```

The --type=LoadBalancer flag indicates that you want to expose your Service outside of the cluster.

2. View the Service you just created:

```
kubectl get services
```
Output:

```
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.108.144.78   <pending>     8080:30369/TCP   21s
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          23m
```
On cloud providers that support load balancers, an external IP address would be provisioned to access the Service. On Minikube, the LoadBalancer type makes the Service accessible through the minikube service command.

Run the following command:

```
minikube service hello-node
```
Katacoda environment only: Click the plus sign, and then click Select port to view on Host 1.

Katacoda environment only: Type 30369 (see port opposite to 8080 in services output), and then click

This opens up a browser window that serves your app and shows the “Hello World” message.

###practice 3: deployments:

1. create a new folder in your desktop called "practice3"
2. create the following file "prcatice3/deployment.yaml"
```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
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

3. Create a Deployment based on the YAML file:
  
```bash
kubectl apply -f practice3/dep.yaml
```
if you didn't create the file
```bash
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
```
4. Display information about the Deployment:
   
```bash
kubectl describe deployment nginx-deployment
```

5. List the pods created by the deployment:
```bash
kubectl get pods -l app=nginx
```
6. Display information about a pod:
```bash
kubectl describe pod <pod-name>
```   

###practice 4: Updating the deployment
1. create the following yaml file "dep2.yaml"
```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
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
        image: nginx:1.8 # Update the version of nginx from 1.7.9 to 1.8
        ports:
        - containerPort: 80
```

2. Apply the new YAML file:
  

```bash
kubectl apply -f dep2.yaml
```
if you didn't create the file:
```bash
 kubectl apply -f https://k8s.io/examples/application/deployment-update.yaml
```
3. Watch the deployment create pods with new names and delete the old pods:
   
```bash
 kubectl get pods -l app=nginx
```


##cleanup
Now you can clean up the resources you created in your cluster:

```kubectl delete service hello-node
kubectl delete deployment hello-node
```
Optionally, stop the Minikube virtual machine (VM):

```
minikube stop
```
Optionally, delete the Minikube VM:
```
minikube delete
```