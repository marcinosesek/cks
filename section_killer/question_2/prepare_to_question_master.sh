NAMESPACE="falco-ns"

kubectl create ns $NAMESPACE

echo "
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: falco-nginx
  name: falco-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: falco-nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: falco-nginx
    spec:
      containers:
      - image: nginx:alpine
        name: falco-nginx
        command: ['/bin/sh']
        args: ['-c', 'while true; do apk search vim; sleep 10; done']
        resources: {}
" > falco-nginx-deployment.yaml

kubectl apply -f falco-nginx-deployment.yaml -n $NAMESPACE

echo "
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: falco-httpd
  name: falco-httpd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: falco-httpd
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: falco-httpd
    spec:
      containers:
      - image: httpd:alpine
        name: falco-httpd
        command: ['/bin/sh']
        args: ['-c', 'while true; do echo hello > /etc/passwd; sleep 10; done']
        resources: {}
" > falco-httpd-deployment.yaml

kubectl apply -f falco-httpd-deployment.yaml -n $NAMESPACE

