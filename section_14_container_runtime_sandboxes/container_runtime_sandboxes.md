# Containers are not containerd

1. Just because it runs in a container does't mean it's mode protected
1. Overview
    ```
    |------------------|
    | DOCKER           |
    | APP1 PROCESS     |
    | KERNEL GROUP     |
    |------------------|
    |      KERNEL      |
    | OPERATING SYSTEM |
    ```
    1. Proces running in one container can send syscalls and break some different docker process because they are runing in the same KERNEL

1. Sandbox
    1. Playground when implementing an API
    1. Imulated testing environment
    1. Development server
    1. Security layer to reduce attack surface

1. Containers and system calls
    ```
    |------------------|---|
    | DOCKER           |   |
    | APP1 PROCESS     |   |-- User Space
    |------------------|
    | SANDBOX          |
    |------------------|---|
    |  System Calls    |---|
    |------------------|   |-- Kernel Space
    |      KERNEL      |---|
    | OPERATING SYSTEM |
    ```
    1. Sandboxes comes not for free

1. Contact the Linux Kenel from inside container
    ```
    kubectl run pod --image=nginx
    kubectl exec pod -it -- bash
    root@pod:/# uname -r
    5.4.0-1028-gcp
    exit

    root@cks-master:~# uname -r
    5.4.0-1028-gcp
    root@cks-master:~# strace uname -r
    ```

1. OCI - Open Container Initialive
    1. Linux Foundation project to design open standard for virtualization
    1. Specifiation
        * runtime, image, distribution
    1. Runtime
        * `runc` (container runtime tTat implements specificaiton)

    1. Dockers does not create containers. They run `OCI/runc` to create containers

1. Kubernetes runtime and CRI (Contaoner Runtime Interface)
    1. It allows recompile `kubelet` to use conrainer runtime
        ```
        kubelet --container-runtime {string}            | RuntimeClass
                --container-runtime-endpoint {string}   | and/or annotations
        ```

1. Critcl and containerd
    1. `crictl` provides CLI for CRI - compatible container runtimes
        ```
        root@kubemaster:~# crictl ps
        CONTAINER ID        IMAGE                                                                                                  CREATED             STATE               NAME                        ATTEMPT             POD ID
        a6c8a46625440       a8c2fdb8bf76e                                                                                          45 hours ago        Running             kube-apiserver              7                   dd387c16b3110
        944a944c4391c       a27166429d98e                                                                                          45 hours ago        Running             kube-controller-manager     5                   6c0ff1d6be78b
        199c409606347       ed2c44fbdd78b                                                                                          45 hours ago        Running             kube-scheduler              5                   6d5755c4ad21d
        557609e71ee87       kubernetesui/metrics-scraper@sha256:1f977343873ed0e2efd4916a6b2f3075f310ff6fe42ee098f54fc58aa7a28ab7   9 days ago          Running             dashboard-metrics-scraper   0                   6252ea04a37dc
        4a1e9242ffcec       bfe3a36ebd252                                                                                          9 days ago          Running             coredns                     0                   dd9574696f947
        2dc465f86fff0       bfe3a36ebd252                                                                                          9 days ago          Running             coredns                     0                   7b847600401c1
        33e157894efda       7f92d556d4ffe                                                                                          9 days ago          Running             weave-npc                   0                   89e7203376b50
        f626420b506ed       df29c0a4002c0                                                                                          9 days ago          Running             weave                       0                   89e7203376b50
        800904a39357b       43154ddb57a83                                                                                          9 days ago          Running             kube-proxy                  0                   f613456b2a02c
        f38c83cc81811       0369cf4303ffd                                                                                          9 days ago          Running             etcd                        0                   5ae430b3a1dd0
        ```

    1. It communicate with docker. We can configure it to run with `containerd`

        ```
        root@kubemaster:~# crictl pods
        POD ID              CREATED             STATE               NAME                                         NAMESPACE              ATTEMPT
        dd387c16b3110       45 hours ago        Ready               kube-apiserver-kubemaster                    kube-system            2
        6252ea04a37dc       9 days ago          Ready               dashboard-metrics-scraper-79c5968bdc-jrrfx   kubernetes-dashboard   0
        dd9574696f947       9 days ago          Ready               coredns-74ff55c5b-rs5f2                      kube-system            1
        7b847600401c1       9 days ago          Ready               coredns-74ff55c5b-72nk9                      kube-system            1
        89e7203376b50       9 days ago          Ready               weave-net-qpl8h                              kube-system            0
        f613456b2a02c       9 days ago          Ready               kube-proxy-2szdd                             kube-system            0
        5ae430b3a1dd0       9 days ago          Ready               etcd-kubemaster                              kube-system            0
        6d5755c4ad21d       9 days ago          Ready               kube-scheduler-kubemaster                    kube-system            0
        6c0ff1d6be78b       9 days ago          Ready               kube-controller-manager-kubemaster           kube-system            0
        root@kubemaster:~# 
        ```

1. Sandbox Runtime Katacontainers
    1. It provides additional isolation with a lightweight VM and indiviual kernels
    1. Strong separation layer
    1. Runs every container in it's own private VM
    1. QEMU as default
        * needs virtualisation, like nested virtualisation in cloud

1. Sandbox Runtime gVisor
    1. user-space kernel for containers
    1. Another layer of separation
    1. NOT hypervisor/VM based
    1. Simulates kernel syscalls with limited funtionality
    1. Runtime caller `runsc`
    ```
    |------------------|
    |  APP PROCESS     |
    |------------------|
    |  System Calls    |
    |------------------|
    |      gVisor      |
    |------------------|
    |  Limited System  |
    |      Calls       |
    |------------------|
    |   HOST KERNEL    |
    |------------------|
    | OPERATING SYSTEM |
    ```

1. RuntimeClasses
    1. Create and use RuntimeClasses

        ```
        apiVersion: node.k8s.io/v1
        kind: RuntimeClass
        metadata:
        name: gvisor
        handler: runsc  
        ```
    
        ```
        kubectl  apply -f rc.yaml 
        runtimeclass.node.k8s.io/gvisor created
        ```
    
    1. Create pod that uses `gvisor` runtime class

        ```
        apiVersion: v1
        kind: Pod
        metadata:
        creationTimestamp: null
        labels:
            run: gvisor
        name: gvisor
        spec:
        runtimeClassName: gvisor
        containers:
        - image: nginx
            name: gvisor
            resources: {}
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        status: {}
        ```

        ```
        root@kubemaster:/home/vagrant/cks/section_14_container_runtime_sandboxes# kubectl  describe po gvisor 
        Name:         gvisor
        Namespace:    default
        Priority:     0
        Node:         kubenode01/192.168.56.3
        Start Time:   Tue, 09 Feb 2021 18:54:42 +0000
        Labels:       run=gvisor
        Annotations:  <none>
        Status:       Pending
        IP:           
        IPs:          <none>
        Containers:
        gvisor:
            Container ID:   
            Image:          nginx
            Image ID:       
            Port:           <none>
            Host Port:      <none>
            State:          Waiting
            Reason:       ContainerCreating
            Ready:          False
            Restart Count:  0
            Environment:    <none>
            Mounts:
            /var/run/secrets/kubernetes.io/serviceaccount from default-token-lmjcv (ro)
        Conditions:
        Type              Status
        Initialized       True 
        Ready             False 
        ContainersReady   False 
        PodScheduled      True 
        Volumes:
        default-token-lmjcv:
            Type:        Secret (a volume populated by a Secret)
            SecretName:  default-token-lmjcv
            Optional:    false
        QoS Class:       BestEffort
        Node-Selectors:  <none>
        Tolerations:     node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                        node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
        Events:
        Type     Reason                  Age               From               Message
        ----     ------                  ----              ----               -------
        Normal   Scheduled               15s               default-scheduler  Successfully assigned default/gvisor to kubenode01
        Warning  FailedCreatePodSandBox  0s (x2 over 15s)  kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = RuntimeHandler "runsc" not supported
        ```

    1. Pod can't be created because `runsc` was not installed and gvisor does not exists

# Resources

1. Container Runtime Landscape
    https://www.youtube.com/watch?v=RyXL1zOa8Bw

1. Gvisor
    https://www.youtube.com/watch?v=kxUZ4lVFuVo

1. Kata Containers
    https://www.youtube.com/watch?v=4gmLXyMeYWI
