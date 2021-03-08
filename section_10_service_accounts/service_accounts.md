# Service accounts

1. Resources managed by K8s API
1. Are namespaces
1. SA "default" in every namespace used by pods
1. Can be used to talk to K8s API - secret that contains token will be used to talk with K8s server

1. Example using servicea accounts
    1. Create service account `accessor`
    1. Create pod `accessor` and use service account `accessor`
    1. Enter to the pod
    1. Check that secret with token was mounted

        ```
        root@accessor:/# mount | grep service
        tmpfs on /run/secrets/kubernetes.io/serviceaccount type tmpfs (ro,relatime)
        root@accessor:/# ls /run/secrets/kubernetes.io/serviceaccount
        ca.crt  namespace  token
        root@accessor:/# 
        ```
    
    1. Try to access K8s service
    
        ```
        root@accessor:/# curl -k https://kubernetes -k
        {
        "kind": "Status",
        "apiVersion": "v1",
        "metadata": {
            
        },
        "status": "Failure",
        "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
        "reason": "Forbidden",
        "details": {
            
        },
        "code": 403
        }
        ```
    
    1.  Try to access K8s service using authorization header
    
        ```
        curl -k https://kubernetes -k -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkFqY2pxckYweGJGYjNGOHpqNVFtazNtNzlsTUJZLU56UGNEREExd3N0bmsifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImFjY2Vzc29yLXRva2VuLW5ibWtoIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFjY2Vzc29yIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiZTJjZjEzNmEtMmZlOS00MjJmLTliM2MtNDAyYTM5OGQ4YmMwIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6YWNjZXNzb3IifQ.G8D9hw31Iey3fsXSmlv6521XiJ4FzGhCSakL3VT-P-TcZmqq_ZsRZvKPBvxxL90uSqQ7-T429qgouT7TjsTqRZTLEeYbkdKoyueb5nZvyWyfAIE-QdC6zmywRqxbE0m0PjqLp20sTLBNFmGy_R-iz-50fZHPWJ_mruuA7tDP8cu6056VJB7cEVfXODCd0HpEwtizExMHwYDxmLZPYYAUeyzn9e25oJDGOz1otu_9mk7npznhtMX5yDRzdtC8aBfEEbPhlxPN8BgP1x41ELPzOYHnnvDOf2Rm42uXPAeHHnE_pJ4QPE5s_TECO3fQOuvy2I625DZNQWnnt0vhYxGRUA"
        {
        "kind": "Status",
        "apiVersion": "v1",
        "metadata": {
            
        },
        "status": "Failure",
        "message": "forbidden: User \"system:serviceaccount:default:accessor\" cannot get path \"/\"",
        "reason": "Forbidden",
        "details": {
            
        },
        "code": 403
        }
        ```
    
    1. Still can't access K8s api but this time as accessor service 
    
1. Disable the mount of ServiceAccount token in pod
    1. It can be disabled on service account and pod level. We need to add `automountServiceAccountToken: false`

1. Limit ServiceAccount permissions
    1. By default all pods using default service account
    1. To check permissions for service account:
        ```
        kubectl auth can-i delete secrets --as system:serviceaccount:default:accessor
        no
        ```
    1. To add `edit` cluster role to serviceaccount:
        ```
        kubectl create clusterrolebinding  accessor --clusterrole edit --serviceaccount default:accessor
        clusterrolebinding.rbac.authorization.k8s.io/accessor created
        root@kubemaster:/home/vagrant/cks/section_10_service_accounts# kubectl auth can-i delete secrets --as system:serviceaccount:default:accessor
        yes
        ```
1. Resources

    https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin
    https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account
