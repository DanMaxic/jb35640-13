



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