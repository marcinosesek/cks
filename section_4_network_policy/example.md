```
# kubectl run frontend --image=nginx
pod/frontend created
#root@kubemaster:~# kubectl run backend --image=nginx
pod/backend created
#kubectl expose pod frontend --port 80
service/frontend exposed
#root@kubemaster:~# kubectl expose pod backend --port 80
service/backend exposed
# root@kubemaster:~# kubectl get pod,svc
NAME           READY   STATUS              RESTARTS   AGE
pod/backend    0/1     ContainerCreating   0          49s
pod/frontend   0/1     ContainerCreating   0          58s
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/backend      ClusterIP   10.111.173.195   <none>        80/TCP    30s
service/frontend     ClusterIP   10.105.56.31     <none>        80/TCP    36s
service/kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   55m
# kubectl exec frontend -- curl backend
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
 % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   597k      0 --:--:-- --:--:-- --:--:--  597k
# kubectl exec backend -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   298k      0 --:--:-- --:--:-- --:--:--  597k
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

# kubectl apply -f default_deny_netpol.yaml
networkpolicy.networking.k8s.io/default-deny created

# kubectl exec backend -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:07 --:--:--     0^C
root@kubemaster:/home/vagrant/cks/section_4_network_policy# kubectl  get netpol^Croot@kubemaster:/home/vagrant/cks/section_4_network_policy# kubectl exec frontend -- curl backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
```
