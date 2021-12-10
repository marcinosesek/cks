# Download K8s binaries from github

1. Go to https://github.com/kubernetes/kubernetes/releases/tag/v1.20.2
1. Then go to the Changelog
1. Download server binaries

    ```
    wget https://dl.k8s.io/v1.20.2/kubernetes-server-linux-amd64.tar.gz
    ```

1. Check binaries checksum

    ```
    # sha256sum kubernetes-server-linux-amd64.tar.gz > compare
    ```

1. Compare checksum with gitlab value

    ```
    # cat compare | uniq
    65abf178782e43bc21e8455ffbfdadf6064dbeae3ff704ccf9e13e8acee18235c280b06778e5de4bd702f5507e1870fe38c561366d125ef4f821ed7aa46e9f45
    ```

# Compare binaries inside of container

1. Extract server binary

    ```
    # tar xzf kubernetes-server-linux-amd64.tar.gz 
    # cd kubernetes/
    root@kubemaster:/tmp/kubernetes# ls
    LICENSES  addons  kubernetes-src.tar.gz  server
    root@kubemaster:/tmp/kubernetes# 
    # cd server/bin
    # ls
    apiextensions-apiserver             kube-proxy.docker_tag
    kube-aggregator                     kube-proxy.tar
    kube-apiserver                      kube-scheduler
    kube-apiserver.docker_tag           kube-scheduler.docker_tag
    kube-apiserver.tar                  kube-scheduler.tar
    kube-controller-manager             kubeadm
    kube-controller-manager.docker_tag  kubectl
    kube-controller-manager.tar         kubelet
    kube-proxy                          mounter
    ```

1. Get kube-apiserver checksum

    ```
    # sha512sum kube-apiserver
    ca0733297d386d3d33e9fde3f5ebb7f8795778624787346af8fa1c87e04e2f52d30545788c70ad009bfa4914189434bc918fcb601dfb3a010797c981ede3ce72  kube-apiserver
    ```

1. Find kube-apiserver docker container

    ```
    # docker ps | grep apiserver
    c87205ba0e71        a8c2fdb8bf76                   "kube-apiserver --ad…"   25 hours ago        Up 25 hours                             k8s_kube-apiserver_kube-apiserver-kubemaster_kube-system_ab00486482074ed154fb8e4a4936d37c_0
    494ce81f1a7f        k8s.gcr.io/pause:3.2           "/pause"                 25 hours ago        Up 25 hours                             k8s_POD_kube-apiserver-kubemaster_kube-system_ab00486482074ed154fb8e4a4936d37c_0
    root@kubemaster:/tmp/kubernetes/server/bin/container-fs# 
    ```

1. Copy kube-apiserver container filesystem

    ```
    # docker cp c87205ba0e71:/ container-fs
    ```

1. Find kube-apiserver in container filesystem

    ```
    # find ./container-fs/ | grep kube-apiserver
    ./container-fs/usr/local/bin/kube-apiserver
    ```

1. Get kube-apiserver checksum

    ```
    # sha512sum ./container-fs/usr/local/bin/kube-apiserver
    ca0733297d386d3d33e9fde3f5ebb7f8795778624787346af8fa1c87e04e2f52d30545788c70ad009bfa4914189434bc918fcb601dfb3a010797c981ede3ce72  ./container-fs/usr/local/bin/kube-apiserver
    ```