# Killer exam questions

1. Contexts

    You have access to multiple clusters from your main terminal through kubectl contexts. 
    1. Write all context names into /opt/course/1/contexts, one per line.
        ```
        kubectl config view -o jsonpath='{range .contexts[*]}{@.name}{"\n"}{end}' > /opt/course/1/contexts
        ```
    1. From the kubeconfig extract the certificate of user restricted@infra-prod and write it decoded to /opt/course/1/cert.
        ```
        kubectl config view -o jsonpath='{.users[?(@.name=="user-2")].user.client-certificate-data}' --raw  | base64 -d > /opt/course/1/cert
        ```

1. Runtime Security with Falco

    Falco is installed with default configuration on node kubenode01. Connect using ssh kubenode01. Use it to:
    1. Find a Pod running image nginx which creates unwanted package management processes inside its container.
        ```
        tail -f /var/log/syslog | grep "Package management"
        19:42:37.441497705: Error Package management process launched in container (user=root user_loginuid=-1 command=apk search vim container_id=3655e1f39593 container_name=k8s_falco-nginx_falco-nginx-67789b7664-dwcqs_falco-ns_08e67a1e-5318-4c15-b5c0-08b50c50312b_0 image=nginx:alpine)

        kubectl get po -A | grep falco-nginx-67789b7664-dwcqs
        falco-ns      falco-nginx-67789b7664-dwcqs         1/1     Running   0          10m

        ```
    1. Find a Pod running image httpd which modifies /etc/passwd.
        ```
        tail -f /var/log/syslog | grep "/etc/passd"
        ...
        19:38:56.573799862: Error File below /etc opened for writing (user=root user_loginuid=-1 command=sh -c while true; do echo hello > /etc/passwd; sleep 10; done parent=containerd-shim pcmdline=containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/e5c10be9b915602b5b79345b5b539d88fb8635df7c64786deed45dda5cea5803 -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runc -systemd-cgroup file=/etc/passwd program=sh gparent=containerd ggparent=systemd gggparent=<NA> container_id=e5c10be9b915 image=httpd)

        docker ps -a | grep e5c10be9b915
        e5c10be9b915        fa848876521a            "/bin/sh -c 'while t…"   5 minutes ago       Up 5 minutes                                  k8s_falco-httpd_falco-httpd-7848d8b9f7-p6llc_falco-ns_6dd54304-11d8-4e7b-8713-1a571fa56b79_0

        kubectl get po -A | grep falco-httpd_falco-httpd-7848d8b9f7-p6llc
        falco-ns      falco-httpd-7848d8b9f7-p6llc         1/1     Running   0          6m14s
        ```
    1. Save the Falco logs for case 1 under /opt/course/2/falco.log in format time,container-id,container-name,user-name. No other information should be in any line. Collect the logs for at least 30 seconds.
        ```
        Update /etc/falco/falco_rules.local.yaml
        ...
        - rule: Launch Package Management Process in Container
        desc: Package management process ran inside container
        condition: >
            spawned_process
            and container
            and user.name != "_apt"
            and package_mgmt_procs
            and not package_mgmt_ancestor_procs
            and not user_known_package_manager_in_container
        output: >
            %evt.time %container.id %container.name %user.name
        priority: ERROR
        tags: [process, mitre_persistence]

        systemctl stop falco
        falco | grep nginx > opt/course/2/falco.log
        Wed Apr  7 19:47:25 2021: Falco version 0.27.0 (driver version 5c0b863ddade7a45568c0ac97d037422c9efb750)
        Wed Apr  7 19:47:25 2021: Falco initialized with configuration file /etc/falco/falco.yaml
        Wed Apr  7 19:47:25 2021: Loading rules from file /etc/falco/falco_rules.yaml:
        Wed Apr  7 19:47:25 2021: Loading rules from file /etc/falco/falco_rules.local.yaml:
        Wed Apr  7 19:47:25 2021: Loading rules from file /etc/falco/k8s_audit_rules.yaml:
        Wed Apr  7 19:47:25 2021: Starting internal webserver, listening on port 8765
        19:47:28.269518982: Error 19:47:28.269518982 3655e1f39593 k8s_falco-nginx_falco-nginx-67789b7664-dwcqs_falco-ns_08e67a1e-5318-4c15-b5c0-08b50c50312b_0 root
        19:47:38.287283431: Error 19:47:38.287283431 3655e1f39593 k8s_falco-nginx_falco-nginx-67789b7664-dwcqs_falco-ns_08e67a1e-5318-4c15-b5c0-08b50c50312b_0 root
        ```

    1. Afterwards remove the threads (both 1 and 2) by scaling the replicas of the Deployments that control the offending Pods down to 0.
        ```
        kubectl scale deploy -n falco-ns falco-httpd --replicas=0
        deployment.apps/falco-httpd scaled
        kubectl scale deploy -n falco-ns falco-nginx --replicas=0
        deployment.apps/falco-nginx scaled
        ```

1. Apiserver Security
    
    You received a list from the DevSecOps team which performed a security investigation of the k8s cluster1 (workload-prod). The list states the following about the apiserver setup:

    1. Anonymous access is allowed
    1. It's accessible on insecure port 8080
    1. It's accessible through a NodePort Service
    
    Change the apiserver setup so that:
    1. No anonymous access is allowed
    1. It's only accessible over HTTPS (disable insecure access)
    1. It's only accessible through a ClusterIP Service

1. Pod Security Policies
    
    There is Deployment docker-log-hacker in Namespace team-red which mounts /var/lib/docker as a hostPath volume on the Node where its running. This means that the Pods can for example read all Docker container logs which are running on the same Node.

    You're asked to forbid this behavior by:

    1. Enabling Admission Plugin PodSecurityPolicy in the apiserver
        ```
        vi /etc/kubernetes/manifests/kube-apiserver.yaml
        ...
        - --enable-admission-plugins=NodeRestriction,PodSecurityPolicy

        ```
    1. Creating a PodSecurityPolicy named psp-mount which allows hostPath volumes only for directory /tmp - `psp-mount.yaml`
       
    1. Creating a ClusterRole named psp-mount which allows to use the new PSP - `psp-mount-cluster-role.yaml`
    1. Creating a RoleBinding named psp-mount in Namespace team-red which binds the new ClusterRole to all ServiceAccounts in the Namespace team-red - `psp-mount-role-binding-team-read.yaml`
    1. Restart the Pod of Deployment docker-log-hacker afterwards to verify new creation is prevented.

    1. PSPs can affect the whole cluster. Should you encounter issues you can always disable the Admission Plugin again.

1. CIS Benchmark

    You're ask to evaluate specific settings of cluster2 against the CIS Benchmark recommendations. Use the tool kube-bench which is already installed on the nodes.

    Connect using ssh cluster2-master1 and ssh cluster2-worker1.

    On the master node ensure (correct if necessary) that the CIS recommendations are set for:

    1. The --profiling argument of the kube-controller-manager
        ```
        kube-bench master

        vi /etc/kubernetes/manifests/kube-controller-manager.yaml
        add 
        - --profiling=false
        ```
    1. The ownership of directory /var/lib/etcd
        ```
        useradd etcd
        chown etcd:etcd /var/lib/etcd
        ```

    On the worker node ensure (correct if necessary) that the CIS recommendations are set for:
    1. The permissions of the kubelet configuration /var/lib/kubelet/config.yaml
        ```
        ls -ltra /var/lib/kubelet/config.yaml
        ```
    1. The --client-ca-file argument of the kubelet
        ```
        vi /var/lib/kubelet/config.yaml
        ...
          x509:
            clientCAFile: /etc/kubernetes/pki/ca.crt
        ```

1. Verify Platform Binaries

    There are four Kubernetes server binaries located at /opt/course/6/binaries. You're provided with the following verified sha512 values for these:

    1. kube-apiserver f417c0555bc0167355589dd1afe23be9bf909bf98312b1025f12015d1b58a1c62c9908c0067a7764fa35efdac7016a9efa8711a44425dd6692906a7c283f032c
    1. kube-controller-manager 60100cc725e91fe1a949e1b2d0474237844b5862556e25c2c655a33boa8225855ec5ee22fa4927e6c46a60d43a7c4403a27268f96fbb726307d1608b44f38a60
    1. kube-proxy 52f9d8ad045f8eee1d689619ef8ceef2d86d50c75a6a332653240d7ba5b2a114aca056d9e513984ade24358c9662714973c1960c62a5cb37dd375631c8a614c6
    1. kubelet 4be40f2440619e990897cf956c32800dc96c2c983bf64519854a3309fa5aa21827991559f9c44595098e27e6f2ee4d64a3fdec6baba8a177881f20e3ec61e26c
        ```
        sha512sum <binary-name>
        ```

    Delete those binaries that don't match with the sha512 values above.

1. Open Policy Agent

    The Open Policy Agent and Gatekeeper have been installed to, among other things, enforce blacklisting of certain image registries. Alter the existing constraint and/or template to also blacklist images from very-bad-registry.com.
    
    Test it by creating a single Pod using image very-bad-registry.com/image in Namespace default, it shouldn't work.

    You can also verify your changes by looking at the existing Deployment untrusted in Namespace default, it uses an image from the new untrusted source. The OPA contraint should throw violation messages for this one.
    ```
    Edit `blacklistimages` constraint template and add this line: `not startswith(image, "very-bad-registry.com/")`
    
    kubectl edit constrainttemplate blacklistimages
    kubectl run po very-bad-registr-pod --image=very-bad-registry.com/image
    Error from server ([denied by pod-trusted-images] not trusted image!): admission webhook "validation.gatekeeper.sh" denied the request: [denied by pod-trusted-images] not trusted image! 
    ```

1. Secure Kubernetes Dashboard

    The Kubernetes Dashboard is installed in Namespace kubernetes-dashboard and is configured to:

    1. Allow users to "skip login"
    1. Allow insecure access (HTTP without authentication)
    1. Allow basic authentication
    1. Allow access from outside the cluster
    
    You are asked to make it more secure by:
    1. Deny users to "skip login"
    1. Deny insecure access, enforce HTTPS (self signed certificates are ok for now)
    1. Add the --auto-generate-certificates argument
    1. Enforce authentication using a token (with possibility to use RBAC)
    1. Allow only cluster internal access

1. AppArmor Profile
    
    Some containers need to run more secure and restricted. There is an existing AppArmor profile located at /opt/course/9/profile for this.

    Install the AppArmor profile on Node cluster1-worker1. Connect using ssh cluster1-worker1.

    Add label security=apparmor to the Node

    Create a Deployment named apparmor in Namespace default with:

    One replica of image nginx:1.19.2
    NodeSelector for security=apparmor
    Single container named c1 with the AppArmor profile enabled
    The Pod might not run properly with the profile enabled. Write the logs of the Pod into /opt/course/9/logs so another team can work on getting the application running.

1. Container Runtime Sandbox gVisor

    Team purple wants to run some of their workloads more secure. Worker node cluster1-worker2 has container engine containerd already installed and its configured to support the runsc/gvisor runtime.

    The cluster1-worker2 kubelet uses containerd instead of docker. Write the two arguments the kubelet has been configured with to use containerd into /opt/course/10/arguments.

    Create a RuntimeClass named gvisor with handler runsc.

    Create a Pod that uses the RuntimeClass. The Pod should be in Namespace team-purple, named gvisor-test and of image nginx:1.19.2. Make sure the Pod runs on cluster1-worker2.

    Write the dmesg output of the successfully started Pod into /opt/course/10/gvisor-test-dmesg.

1. Secrets in ETCD

    There is an existing Secret called database-access in Namespace team-green.

    Read the complete Secret content from ETCD and store it into /opt/course/11/etcd-secret-content. Write the plain and decoded Secret's value of key "pass" into /opt/course/11/database-password.

1. Hack Secrets

    You're asked to investigate a possible permission escape in Namespace restricted. The context authenticates as user restricted which has only limited permissions and shouldn't be able to read Secret values.

    Try to find the password-key values of the Secrets secret1, secret2 and secret3 in Namespace restricted. Write the decoded plaintext values into files /opt/course/12/secret1, /opt/course/12/secret2 and /opt/course/12/secret3.

1. Restrict access to Metadata Server
    
    There is a metadata service available at http://192.168.100.21:32000 on which Nodes can reach sensitive data, like cloud credentials for initialisation. By default, all Pods in the cluster also have access to this endpoint. The DevSecOps team has asked you to restrict access to this metadata server.

    In Namespace metadata-access:

    Create a NetworkPolicy named metadata-deny which prevents egress to 192.168.100.21 for all Pods but still allows access to everything else
    Create a NetworkPolicy named metadata-allow which allows Pods having label role: metadata-accessor to access endpoint 192.168.100.21
    There are existing Pods in the target Namespace with which you can test your policies, but don't change their labels.

1. Syscall Activity

    There are Pods in Namespace team-yellow. A security investigation noticed that some processes running in these Pods are using the Syscall kill, which is forbidden by a Team Yellow internal policy.

    Find the offending Pod(s) and remove these by reducing the replicas of the parent Deployment to 0.

1.  Configure TLS on Ingress

    In Namespace team-pink there is an existing Nginx Ingress resources named secure which accepts two paths /app and /api which point to different ClusterIP Services.

    From your main terminal you can connect to it using for example:

    HTTP: curl -v http://secure-ingress.test:31080/app
    HTTPS: curl -kv https://secure-ingress.test:31443/app
    Right now it uses a default generated TLS certificate by the Nginx Ingress Controller.

    You're asked to instead use the key and certificate provided at /opt/course/15/tls.key and /opt/course/15/tls.crt. As it's a self-signed certificate you need to use curl -k when connecting to it.

1. Docker Image Attack Surface

    There is a Deployment image-verify in Namespace team-blue which runs image registry.killer.sh:5000/image-verify:v1. DevSecOps has asked you to improve this image by:

    Changing the base image to alpine:3.12
    Not installing curl
    Updating nginx to version >=1.18.0
    Running the main process as user myuser
    Do not add any new lines to the Dockerfile, just edit existing ones. The file is located at /opt/course/16/image/Dockerfile.

    Tag your version as v2. You can build, tag and push using:


    cd /opt/course/16/image
    sudo docker build -t registry.killer.sh:5000/image-verify:v2 .
    sudo docker run registry.killer.sh:5000/image-verify:v2 # to test your changes
    sudo docker push registry.killer.sh:5000/image-verify:v2
    Make the Deployment use your updated image tag v2.

1. Audit Log Policy
    
    Audit Logging has been enabled in the cluster with an Audit Policy located at /etc/kubernetes/audit/policy.yaml on cluster2-master1.

    Change the configuration so that only one backup of the logs is stored.

    Alter the Policy in a way that it only stores logs:

    From Secret resources, level Metadata
    From "system:nodes" userGroups, level RequestResponse
    After you altered the Policy make sure to empty the log file so it only contains entries according to your changes, like using truncate -s 0 /etc/kubernetes/audit/logs/audit.log.

1. Investigate Break-in via Audit Log

    Namespace security contains five Secrets of type Opaque which can be considered highly confidential. The latest Incident-Prevention-Investigation revealed that ServiceAccount p.auster had too broad access to the cluster for some time. This SA should've never had access to any Secrets in that Namespace.

    Find out which Secrets in Namespace security this SA did access by looking at the Audit Logs under /opt/course/18/audit.log.

    Change the password to any new string of only those Secrets that were accessed by this SA.

1. Immutable Root FileSystem

    The Deployment immutable-deployment in Namespace team-purple should run immutable, it's created from file /opt/course/19/immutable-deployment.yaml. Even after a successful break-in, it shouldn't be possible for an attacker to modify the filesystem of the running container.

    Modify the Deployment in a way that no processes inside the container can modify the local filesystem, only /tmp directoy should be writeable. Don't modify the Docker image.

    Save the updated YAML under /opt/course/19/immutable-deployment-new.yaml and update the running Deployment.

 1. Update Kubernetes
    The cluster is running Kubernetes 1.18.6. Update it to 1.19.4 available via apt package manager.

    Use ssh cluster3-master1 and ssh cluster3-worker1 to connect to the instances.

1. Image Vulnerability Scanning

    The Vulnerability Scanner trivy is installed on your main terminal. Use it to scan the following images for known CVEs:

    nginx:1.16.1-alpine
    k8s.gcr.io/kube-apiserver:v1.18.0
    k8s.gcr.io/kube-controller-manager:v1.18.0
    docker.io/weaveworks/weave-kube:2.7.0
    Write all images that don't contain the vulnerabilities CVE-2020-10878 or CVE-2020-1967 into /opt/course/21/good-images.

1. Manual Static Security Analysis

    (can be solved in any kubectl context)

    The Release Engineering Team has shared some YAML manifests and Dockerfiles with you to review. The files are located under /opt/course/22/files.

    As a container security expert, you are asked to perform a manual static analysis and find out possible security issues with respect to unwanted credential exposure.

    Write the filenames which have issues into /opt/course/22/security-issues.

    

    NOTE: In the Dockerfile and YAML manifests, assume that the referred files, folders, secrets and volume mounts are present. Disregard syntax or logic errors.
    
1. You have admin access to cluster2. There is also context gianna@infra-prod which authenticates as user gianna with the same cluster.

    There are existing cluster-level RBAC resources in place to, among other things, ensure that user gianna can never read Secret contents cluster-wide. Confirm this is correct or restrict the existing RBAC resources to ensure this.

    I addition, create more RBAC resources to allow user gianna to create Pods and Deployments in Namespaces security, restricted and internal. It's likely the user will receive these exact permissions as well for other Namespaces in the future.

1. There is an existing Open Policy Agent + Gatekeeper policy to enforce that all Namespaces need to have label security-level set. Extend the policy constraint and template so that all Namespaces also need to set label management-team. Any new Namespace creation without these two labels should be prevented.

    Write the names of all existing Namespaces which violate the updated policy into /opt/course/p2/fix-namespaces.

 1. A security scan result shows that there is an unknown miner process running on one of the Nodes in cluster3. The report states that the process is listening on port 6666. Kill the process and delete the binary.
