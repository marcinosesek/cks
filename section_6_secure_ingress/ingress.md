# What is Ingress

* ClusterIP service points to the pods via labels
* NodePort service creates ClusterIP service and make it abvailable from the outside
* LoadBalancer creates NodePort service
* NodePort service creates ClusterIP service and make it abvailable from the outside

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
## Expose services on Ingress Controller

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

# Setup Ingress in secure mode

1. If we access ingress via https it works but ingres controller serves Fake Certificate

    ```
    # curl -k https://192.168.56.3:31180/service1 -vvv
    *   Trying 192.168.56.3...
    * TCP_NODELAY set
    * Connected to 192.168.56.3 (192.168.56.3) port 31180 (#0)
    * ALPN, offering h2
    * ALPN, offering http/1.1
    * successfully set certificate verify locations:
    *   CAfile: /etc/ssl/certs/ca-certificates.crt
    CApath: /etc/ssl/certs
    * TLSv1.3 (OUT), TLS handshake, Client hello (1):
    * TLSv1.3 (IN), TLS handshake, Server hello (2):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Unknown (8):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Certificate (11):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, CERT verify (15):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Finished (20):
    * TLSv1.3 (OUT), TLS change cipher, Client hello (1):
    * TLSv1.3 (OUT), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (OUT), TLS handshake, Finished (20):
    * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
    * ALPN, server accepted to use h2
    * Server certificate:
    *  subject: O=Acme Co; CN=Kubernetes Ingress Controller Fake Certificate
    *  start date: Jan 31 15:55:13 2021 GMT
    *  expire date: Jan 31 15:55:13 2022 GMT
    *  issuer: O=Acme Co; CN=Kubernetes Ingress Controller Fake Certificate
    *  SSL certificate verify result: unable to get local issuer certificate (20), continuing anyway.
    * Using HTTP2, server supports multi-use
    * Connection state changed (HTTP/2 confirmed)
    * Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * Using Stream ID: 1 (easy handle 0x55d3e2771580)
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    > GET /service1 HTTP/2
    > Host: 192.168.56.3:31180
    > User-Agent: curl/7.58.0
    > Accept: */*
    > 
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    * Connection state changed (MAX_CONCURRENT_STREAMS updated)!
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    < HTTP/2 200 
    < date: Sun, 31 Jan 2021 19:54:02 GMT
    < content-type: text/html
    < content-length: 612
    < last-modified: Tue, 15 Dec 2020 13:59:38 GMT
    < etag: "5fd8c14a-264"
    < accept-ranges: bytes
    < strict-transport-security: max-age=15724800; includeSubDomains
    < 
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
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    * Connection #0 to host 192.168.56.3 left intact
    ```

1. We need to change this to use our own certificate
1. Generate self signed certificate
    ```
    # openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
    Can't load /root/.rnd into RNG
    140567754011072:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/root/.rnd
    Generating a RSA private key
    ......................................................++++
    ........................++++
    writing new private key to 'key.pem'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [AU]:
    State or Province Name (full name) [Some-State]:
    Locality Name (eg, city) []:
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:
    Organizational Unit Name (eg, section) []:
    Common Name (e.g. server FQDN or YOUR name) []:secure-ingress.com
    Email Address []:
    ```

1. Create secret for ingress

    ```
    # kubectl create secret tls secure-ingress --cert=./cert.pem --key=./key.pem 
    secret/secure-ingress created
    # kubectl  get secret
    NAME                  TYPE                                  DATA   AGE
    default-token-lmjcv   kubernetes.io/service-account-token   3      22h
    secure-ingress        kubernetes.io/tls                     2      23s
    ```

1. Modify `ingress.yaml` and add tls section and host to the rules 
1. Check ingress is using our certificate add `--resolve secure-ingress.com:31180:192.168.56.3` to the curl command
    
    ```
    # curl -k https://secure-ingress.com:31180/service1 --resolve secure-ingress.com:31180:192.168.56.3 -vvv
    * Added secure-ingress.com:31180:192.168.56.3 to DNS cache
    * Hostname secure-ingress.com was found in DNS cache
    *   Trying 192.168.56.3...
    * TCP_NODELAY set
    * Connected to secure-ingress.com (192.168.56.3) port 31180 (#0)
    * ALPN, offering h2
    * ALPN, offering http/1.1
    * successfully set certificate verify locations:
    *   CAfile: /etc/ssl/certs/ca-certificates.crt
    CApath: /etc/ssl/certs
    * TLSv1.3 (OUT), TLS handshake, Client hello (1):
    * TLSv1.3 (IN), TLS handshake, Server hello (2):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Unknown (8):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Certificate (11):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, CERT verify (15):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Finished (20):
    * TLSv1.3 (OUT), TLS change cipher, Client hello (1):
    * TLSv1.3 (OUT), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (OUT), TLS handshake, Finished (20):
    * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
    * ALPN, server accepted to use h2
    * Server certificate:
    *  subject: C=AU; ST=Some-State; O=Internet Widgits Pty Ltd; CN=secure-ingress.com
    *  start date: Jan 31 19:58:08 2021 GMT
    *  expire date: Jan 31 19:58:08 2022 GMT
    *  issuer: C=AU; ST=Some-State; O=Internet Widgits Pty Ltd; CN=secure-ingress.com
    *  SSL certificate verify result: self signed certificate (18), continuing anyway.
    * Using HTTP2, server supports multi-use
    * Connection state changed (HTTP/2 confirmed)
    * Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * Using Stream ID: 1 (easy handle 0x5612a153e580)
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    > GET /service1 HTTP/2
    > Host: secure-ingress.com:31180
    > User-Agent: curl/7.58.0
    > Accept: */*
    > 
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.3 (IN), TLS Unknown, Certificate Status (22):
    * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    * Connection state changed (MAX_CONCURRENT_STREAMS updated)!
    * TLSv1.3 (OUT), TLS Unknown, Unknown (23):
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    < HTTP/2 200 
    < date: Sun, 31 Jan 2021 20:07:46 GMT
    < content-type: text/html
    < content-length: 612
    < last-modified: Tue, 15 Dec 2020 13:59:38 GMT
    < etag: "5fd8c14a-264"
    < accept-ranges: bytes
    < strict-transport-security: max-age=15724800; includeSubDomains
    < 
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
    * TLSv1.3 (IN), TLS Unknown, Unknown (23):
    * Connection #0 to host secure-ingress.com left intact
    ```