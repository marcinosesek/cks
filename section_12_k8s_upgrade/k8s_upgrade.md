# K8s upgrade

1. Kubernetes Release Cycles

    ```
    major minor patch
        1.19.2
    ```

1. Minor versions every 3 months, No LTS (Long Term Support)
1. Maintenance release branches for the most recent 3 minor releases
1. How to upgrade a cluster
    1. First upgrade the master components
        * apiserver, controller-manager, scheduler
    1. Then the worker components
        * kubelet, kube-proxy
    1. Components same minor version as apiserver or one bellow

1. How to upgrade a node
    1. `kubectl drain`
    1. Do the upgrade
    1. `kubectl uncordon`

# Resources

1. kubeadm upgrade
    
    https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade

1. k8s versions
    
    https://kubernetes.io/docs/setup/release/version-skew-policy
