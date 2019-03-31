# Docker cheat sheet

## Basic docker operations
### **Instecting what containers are running**
```bash
docker ps
```
Best practice: run always "docker ps -a"

### **Pull docker container from a registry (artifactory)**
```bash
docker pull <image-id:tag>
```
### **Run docker container**
```bash
docker run -itd <image-id:tag>
docker run -itd –name ubuntu-cont ubuntu
```
### **Pause container**
```
docker pause <container-id/name>
```
### **Unpause container**
```
docker unpause <container-id/name>
```
### **Start container**
```
docker start <container-id/name>
```
### **Stop container**
```
docker stop <container-id/name>
```
### **Restart container**
```
docker restart <container-id/name>
```
### **Kill container**
```
docker kill <container-id/name>
```
### **Destroy container**
 ```
docker rm <container-id/name> 
``` 
### **usefull tip:**
to remove & kill all running containers, run the following:
```bash
#kill all running containers:
docker kill $(docker ps -qa)
docker rm -f $(docker ps -qa)
```

## Advances operations: **Debugging your container:**
### **inspect the logs of a container:**
```
docker logs <container-id/name>
```

### **logging into container and excecute commands:**
```
docker exec -it <container-id/name> /bin/sh
```

### **getting statistics on containers:**
```
docker exec -it <container-id/name> /bin/sh
```

### **Getting ui for view statistics**
```bash
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/cgroup:/cgroup:ro \
  --privileged=true \
  --publish=4040:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest
```