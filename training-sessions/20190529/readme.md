

## Exercise: Deploy a Job
Applications that run to completion inside a pod are called "jobs."  This is useful for doing batch processing.
Most Kubernetes objects are created using yaml. Here is some sample yaml for a job which uses perl to calculate pi to 2000 digits and then stops.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
Create this yaml file on your master node and call it "pi-job.yaml". Run the job with the command:
```
kubectl create -f pi-job.yaml
1. Check the status of the job using the kubectl describe command.

2. When the job is complete, view the results by using the kubectl logs command on the appropriate pod.

3. Write yaml for a new job.  Use the image "busybox" and have it sleep for 10 seconds and then complete.  Run your job to be sure it works.


## Exercise: Deploy a Pod
Pods usually represent running applications in a Kubernetes cluster.  Here is an example of some yaml which defines a pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine
  namespace: default
spec:
  containers:
  - name: alpine
    image: alpine
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
```
1. Looking at the yaml, describe what the pod will do.

2. Run the pod.

3. Delete the pod.

4. Write yaml for a pod that runs the nginx image.

5. Run your yaml to ensure it functions as expected.

Delete any user pods you created during this exercise.

## Exercise: Deployments

Here is some yaml for an nginx deployment:
```yaml

apiVersion: apps/v1beta2
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
1. Create the deployment.

2. Which nodes are the pods running on. How can you tell?

3. Update the deployment to use the 1.8 version of the nginx container and roll it out.

4. Update the deployment to use the 1.9.1 version of the nginx container and roll it out.

5. Roll back the deployment to the 1.8 version of the container.

6. Remove the deployment


LSN:
Create the yaml file and name it something. I chose nginx-deployment.yaml. Create the deployment object by calling:
```bash
kubectl create -f nginx-deployment.yaml
```
There are many ways to get this, here's one example that gives you the results in one step and uses a label selector:
```bash
kubectl get pods -l app=nginx -o wide
```
There are many ways. Here are two:
This will work just fine but is not the preferredmethodbecausenowtheyaml is inconsistent with what you've got running in the cluster. Anyonecomingacrossyouryaml will assume it's what is up and running and it isn't.
```bash
kubectl set image deployment nginx-deployment nginx=nginx:1.8
```
Updatethelineintheyaml to the 1.8 version of the image, and apply the changes with
```bash
kubectl apply -f nginx-deployment.yaml
```
Same as above. Don't forget you can watch the status of the rollout with the command
```bash
kubectl rollout status deployment nginx-deployment
kubectl rollout undo deployment nginx-deployment
```
will undo the previous rollout, or if you want to go to a specific point in history, you can view the history and roll back to a specific state with:
```bash
kubectl rollout history deployment nginx-deployment
kubectl rollout undo deployment nginx-deployment --to-revision=x
kubectl delete -f nginx-deployment.yaml
```

##Exercise: Scaling Practice
Consider this YAML for an nginx deployment:

```yaml
apiVersion: apps/v1beta2
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
        image: nginx
        ports:
        - containerPort: 80
```


Complete and answer the following:

Scale the deployment up to 4 pods without editing the YAML.
Edit the YAML so that 3 pods are available and can apply the changes to the existing deployment.
Which of these methods do you think is preferred and why?

SLN:
```bash
kubectl scale deployment nginx-deployment --replicas=4
```

## Exercise: Replication Controllers, Replica Sets, and Deployments

Deployments replaced the older ReplicationController functionality, but it never hurts to know where you came from.  Deployments are easier to work with, and here's a brief exercise to show you how.

A Replication Controller ensures that a specified number of pod replicas are running at any one time. In other words, a Replication Controller makes sure that a pod or a homogeneous set of pods is always up and available.

Write a YAML file that will create a Replication Controller that will maintain three copies of an nginx container.  Execute your YAML and make sure it works.
A Replica Set is a more advanced version of a Replication Controller that is used when more low-level control is needed.  While these are commonly managed with deployments in modern K8s, it's good to have experience with them.

Write the YAML that will maintain three copies of an nginx container using a Replica Set.  Test it to be sure it works, then delete it.
A deployment is used to manage Replica Sets.  

Write the YAML for a deployment that will maintain three copies of an nginx container.  Test it to be sure it works, then delete it.
 
To create the replication controller, write the following YAML file:

Replication Controller:

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```
To maintain three copies of an nginx container in a replica set, write the following YAML file: 

Replication Set:

```yaml
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```
To perform a deployment for the Replica Set, write the following YAML file:

Deployment:

apiVersion: apps/v1beta2 # for versions before 1.8.0 use apps/v1beta1
```bash
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

##Exercise: View the Logs

Create this object in your cluster:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: counter
  labels:
    demo: logger
spec:
  containers:
  - name: count
    image: busybox
    args: [/bin/sh, -c, 'i=0; while true; do echo "$i: $(date)"; i=$((i+1)); sleep 3; done']

```
This is a small container which wakes up every three seconds and logs the date and a count to stdout.

1. View the current logs of the counter.
2. Allow the container to run for a few minutes while viewing the log interactively.
3. Have the command only print the last 10 lines of the log.
4. Look at the logs for the scheduler. Have there been any problems lately that you can see?
5. Kubernetes uses etcd for its key-value store. Take a look at its logs and see if it has had any problems lately.
6. Kubernetes API server also runs as a pod in the cluster. Find and examine its logs.

SLN:
1. kubectl logs counter
2. kubectl logs counter -f
3. kubectl logs counter --tail=10 or, since --tail defaults to 10, just kubectl logs counter --tail
4. This question really wants to know if you can find the logs for the scheduler. They're in the master in the /var/log/containers directory. There, a symlink has been create to the appropriate container's log file, and the symlink will have a name that begins with "kube-scheduler-" These logs belong to root, so you will have to sudo to view them.
5. The etcd logs are in the same directory as the logs for the previous question, only the name of the symlink begins with "etcd-", and also belongs to root.
6. The API server also lives in the same directory and begins with "kube-apiserver-", and also belongs to root.

##Exercise: Label ALL THE THINGS!
Putting labels on objects in Kubernetes allow you to identify and select objects in as wide or granular style as you like.
1. Label each of your nodes with a "color" tag. The master should be black; node 2 should be red; node 3 should be green and node 4 should be blue.
2. If you have pods already running in your cluster in the default namespace, label them with the key/value pair running=beforeLabels.
3. Create a new alpine deployment that sleeps for one minute and is then restarted from a yaml file that you write that labels these container with the key/value pair running=afterLabels.
4. List all running pods in the default namespace that have the key/value pair running=beforeLabels.
5. Label all pods in the default namespace with the key/value pair tier=linuxAcademyCloud.
6. List all pods in the default namespace with the key/value pair running=afterLabels and tier=linuxAcademyCloud.

SLN:
1.

kubectl label node node1-name color=black for the master.
kubectl label node node2-name color=red for node 2.
kubectl label node node3-name color=green for node 3.
kubectl label node node4-name color=blue for node 4.
2. kubectl label pods -n default running=beforeLabels --all
3. alpine-label.yaml:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine
  namespace: default
  labels:
    running: afterLabels
spec:
  containers:
  - name: alpine
    image: alpine
    command:
      - sleep
      - "60"
  restartPolicy: Always
```
4. kubectl get pods -l running=beforeLabels -n default
5. kubectl label pods --all -n default tier=linuxAcademyCloud
6. kubectl get pods -l running=afterLabels,tier=linuxAcademyCloud
