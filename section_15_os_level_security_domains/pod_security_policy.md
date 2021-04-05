# PodSecurityPolicy - AdmissionController

1. It's not enabled by default. To enable it need to modify kube-apiserver manifest

    ```
    ...
    containers:
      - command:
          - kube-apiserver
          - --enable-admission-plugin=PodSecurityPolicy
    ```

1. We can create pod using `kubectl run nginx --image=nginx` because we have admin rights. 

1. We can't create new deployment because default service account does not know that it should use psp.

1. Give default service account access to psp

    ```
    kubectl create role psp-access --verb=use --resource=podsecuritypolicies
    role.rbac.authorization.k8s.io/psp-access created
    root@kubemaster:/home/vagrant/cks/section_15_os_level_security_domains# kubectl  create  rolebinding psp-access --role=psp-access --serviceaccount=default:default
    rolebinding.rbac.authorization.k8s.io/psp-access created
    ```

1. Create deployment

    ```
    kubectl create deployment nginx --image=nginx
    deployment.apps/nginx created
    root@kubemaster:/home/vagrant/cks/section_15_os_level_security_domains# kubectl describe deployments.apps nginx 
    Name:                   nginx
    Namespace:              default
    CreationTimestamp:      Tue, 09 Feb 2021 20:50:02 +0000
    Labels:                 app=nginx
    Annotations:            deployment.kubernetes.io/revision: 1
    Selector:               app=nginx
    Replicas:               1 desired | 1 updated | 1 total | 0 available | 1 unavailable
    StrategyType:           RollingUpdate
    MinReadySeconds:        0
    RollingUpdateStrategy:  25% max unavailable, 25% max surge
    Pod Template:
    Labels:  app=nginx
    Containers:
    nginx:
        Image:        nginx
        Port:         <none>
        Host Port:    <none>
        Environment:  <none>
        Mounts:       <none>
    Volumes:        <none>
    Conditions:
    Type           Status  Reason
    ----           ------  ------
    Available      False   MinimumReplicasUnavailable
    Progressing    True    ReplicaSetUpdated
    OldReplicaSets:  <none>
    NewReplicaSet:   nginx-6799fc88d8 (1/1 replicas created)
    Events:
    Type    Reason             Age   From                   Message
    ----    ------             ----  ----                   -------
    Normal  ScalingReplicaSet  10s   deployment-controller  Scaled up replica set nginx-6799fc88d8 to 1
    ```

1. Create pod with allowedPrivilegeEscalation enabled 

    ```
    kubectl apply -f pod-psp.yaml 
    Error from server (Forbidden): error when creating "pod-psp.yaml": pods "pod-sc" is forbidden: PodSecurityPolicy: unable to admit pod: [spec.containers[0].securityContext.allowPrivilegeEscalation: Invalid value: true: Allowing privilege escalation for containers is not allowed]
    ```

    1. Pod can't start because PSP block it

