# Security Contexts

1. Define privilege and access control for Pod/Container
1. userID and groupID
1. Run privileged or unprivileged
1. Linux Capabilities

1. Create pod with security context
    ```
    kubectl apply -f pod-sc.yaml
    ```

    ```
    kubectl exec -it pod-sc  sh
    kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
    / $ id
    uid=1000 gid=3000
    / $ touch test
    touch: test: Permission denied
    ```

1. Create pod and run container as non root
    ```
    kubectl apply -f pod-sc-non-root.yaml
    ```
    ```
    kubectl describe pod pod-sc
    ...
    Events:
    Type     Reason          Age               From               Message
    ----     ------          ----              ----               -------
    Normal   Scheduled       12s               default-scheduler  Successfully assigned default/pod-sc to kubenode01
    Normal   Pulled          6s                kubelet            Successfully pulled image "busybox" in 4.303159336s
    Warning  Failed          6s                kubelet            Error: container has runAsNonRoot and image will run as root (pod: "pod-sc_default(f534f9df-7772-4b02-9452-6ee7360602e3)", container: pod)
    Normal   SandboxChanged  5s                kubelet            Pod sandbox changed, it will be killed and re-created.
    Normal   Pulling         4s (x2 over 10s)  kubelet            Pulling image "busybox"
    ```

1. By default docker containers run `unprivileged`. 
    1. It's possible to run it as privileged that allows access to all devices
        ```
        docker run --privileged
        ```
    1. Privileged means that container user 0 (root) is directly mapped to host user 0 (root)
    1. Create pod with privileged mode

        ```
        kubectl  apply -f pod-sc-privileged.yaml

        kubectl exec -it pod-sc sh
        kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
        / # id
        uid=0(root) gid=0(root) groups=10(wheel)
        / # sysctl kernel.hostname=attacker
        kernel.hostname = attacker
        / # hostname
        attacker
        ```

1. PrivilegeEscalation
    1. Controls whether a process can gain more privileges than its parent process - it's enabled by default
    1. Create pod with `allowPrivilegesEscalation` set to true

        ```
        kubectl apply -f pod-sc-privileged-escalation.yaml 
        ```

        ```
        kubectl exec -it pod-sc sh
        kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
        / # cat /proc/1/status | grep NoNew
        NoNewPrivs:     0
        / # 
        ```

    1. Create pod with `allowPrivilegesEscalation` set to true

        ```
        kubectl apply -f pod-sc-privileged-escalation-disabled.yaml 
        ```

        ```
        kubectl exec -it pod-sc sh
        kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
        / # cat /proc/1/status | grep NoNew
        NoNewPrivs:     1
        / # 
        ```