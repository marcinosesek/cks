# Install K8s Dashboard

1. To install search in google K8s dashboard gitlab repository
2. On master node run
    ```
    # kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml
    ```
# Access K8s dashboard

1. Bad example is to expose K8s Dashboard externally !!
1. To enable external access edit K8s Dashboard deployment
    1. Remove: `--auto-generate-certificates`
    1. Add: `--insecure-port=9090`
    1. Remove `livenessProbe` or change port/protocol in livenessProbe
        ```
        ...
        containers:
        - args:
            - --namespace=kubernetes-dashboard
            - --insecure-port=9090
            image: kubernetesui/dashboard:v2.1.0
            imagePullPolicy: Always
            livenessProbe:
            failureThreshold: 3
            httpGet:
                path: /
                port: 9090
                scheme: HTTP
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 30
        ```
1. To access K8s Dasboard need to go to node ip and K8s service port
    1. Get node ip
        ```
        # kubectl get nodes -o wide
        NAME         STATUS   ROLES                  AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
        kubemaster   Ready    control-plane,master   17h   v1.20.2   192.168.56.2   <none>        Ubuntu 18.04.5 LTS   4.15.0-124-generic   docker://19.3.6
        kubenode01   Ready    <none>                 17h   v1.20.2   192.168.56.3   <none>        Ubuntu 18.04.5 LTS   4.15.0-124-generic   docker://19.3.6
        ```
    
    1. Get K8s Dashboard service port
        ```
        # kubectl get svc -n kubernetes-dashboard 
        NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
        dashboard-metrics-scraper   ClusterIP   10.111.96.81   <none>        8000/TCP         117m
        kubernetes-dashboard        NodePort    10.97.47.43    <none>        9090:31704/TCP   117m
        ```

    1. Access K8s Dashboard from browser
        ```
        http://192.168.56.3:31704
        ```

    1. On K8s Dashboard we can't see to much because it's blocked due to RBAC

    1. Create rolebining for K8s Dashboard service account
        ```
        # kubectl -n kubernetes-dashboard create rolebinding insecure --serviceaccount kubernetes-dashboard:kubernetes-dashboard --clusterrole view
        ```
    1. To add K8s Dashboard more access we can create clusterrolebinding and bind it to serviceaccount
        ```
        # kubectl -n kubernetes-dashboard create clusterrolebinding insecure --serviceaccount kubernetes-dashboard:kubernetes-dashboard --clusterrole view
        ```

# Resources

    https://github.com/kubernetes/dashboard/blob/master/docs/common/dashboard-arguments.md  

    https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md
