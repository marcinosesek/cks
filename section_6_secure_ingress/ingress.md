# What is Ingress
    1. ClusterIP service points to the pods via labels
    1. NodePort service creates ClusterIP service and make it abvailable from the outside
    1. LoadBalancer creates NodePort service 4. NodePort service creates ClusterIP service and make it abvailable from the outside

# Setup Ingress in insecure mode
    1. To install Ingress controller go to Ingress controller webpage and find instructions for Baremetal
        ```
        # kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.43.0/deploy/static/provider/baremetal/deploy.yaml
        namespace/ingress-nginx created
        serviceaccount/ingress-nginx created
        configmap/ingress-nginx-controller created
        clusterrole.rbac.authorization.k8s.io/ingress-nginx created
        clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
        role.rbac.authorization.k8s.io/ingress-nginx created
        rolebinding.rbac.authorization.k8s.io/ingress-nginx created
        service/ingress-nginx-controller-admission created
        service/ingress-nginx-controller created
        deployment.apps/ingress-nginx-controller created
        validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
        serviceaccount/ingress-nginx-admission created
        clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
        clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
        role.rbac.authorization.k8s.io/ingress-nginx-admission created
        rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
        job.batch/ingress-nginx-admission-create created
        job.batch/ingress-nginx-admission-patch created
        ```
    1. Now we can access Ingress controlled via node ip and ingress controller service node port
        ```
        # kubectl get nodes -o wide
        NAME         STATUS   ROLES                  AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
        kubemaster   Ready    control-plane,master   18h   v1.20.2   192.168.56.2   <none>        Ubuntu 18.04.5 LTS   4.15.0-124-generic   docker://19.3.6
        kubenode01   Ready    <none>                 18h   v1.20.2   192.168.56.3   <none>        Ubuntu 18.04.5 LTS   4.15.0-124-generic   docker://19.3.6
        ```

        ```
        # kubectl get svc -n ingress-nginx 
        NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
        ingress-nginx-controller             NodePort    10.110.145.53   <none>        80:31689/TCP,443:31180/TCP   8m4s
        ingress-nginx-controller-admission   ClusterIP   10.102.59.86    <none>        443/TCP                      8m4s
        ```

        ```
        # curl 192.168.56.3:31689
        <html>
        <head><title>404 Not Found</title></head>
        <body>
        <center><h1>404 Not Found</h1></center>
        <hr><center>nginx</center>
        </body>
        </html>
        ```
# Expose services on Ingress Controller

1. Create ingress object
    ```
    # kubectl apply -f ingress.yaml
    ```
1. Deploy and expose pods
    ```
    # kubectl run pod1 --image=nginx
    pod/pod1 created
    # kubectl run pod2 --image=httpd
    pod/pod2 created
    # kubectl expose pod pod1 --port 80 --name=service1
    service/service1 exposed
    # kubectl expose pod pod2 --port 80 --name=service2
    service/service2 exposed
    ```

1. Access Ingress services
    ```
    # curl 192.168.56.3:31689/service2
    <html><body><h1>It works!</h1></body></html>
    # curl 192.168.56.3:31689/service1
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>
    ```