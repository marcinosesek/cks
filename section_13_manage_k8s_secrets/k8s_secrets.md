# Secrets

1. Access to the secrets from docker on worker node
    1. We can run `docker inspect <container id>` and see secrets stored in environment variables
    1. We can copy file system via `docker cp` and see secrets mounted as volumes 

1. Access to secrets from etcd
    1. Check access to ETCD

        ```
        ETCDCTL_API=3 etcdctl --cert /etc/kubernetes/pki/apiserver-etcd-client.crt --key /etc/kubernetes/pki/apiserver-etcd-client.key --cacert /etc/kubernetes/pki/etcd/ca.crt endpoint health
        127.0.0.1:2379 is healthy: successfully committed proposal: took = 879.207µs
        ```
    
    1. Get secrets from ETCD
    
        ```
        ETCDCTL_API=3 etcdctl --cert /etc/kubernetes/pki/apiserver-etcd-client.crt --key /etc/kubernetes/pki/apiserver-etcd-client.key --cacert /etc/kubernetes/pki/etcd/ca.crt get /registry/secrets/default/secret2
        /registry/secrets/default/secret2
        k8s


        v1Secret�
        �
        secret2default"*$7db9799d-84dd-42d0-9cea-1ea9f35d69d32����z�_
        kubectl-createUpdatev����FieldsV1:-
        +{"f:data":{".":{},"f:pass":{}},"f:type":{}}
        pas12345678Opaque"
        ```
1. Secrets are not encrypted in ETCD by default
1. Encrypt ETCD
    1. Create `EncryptionConfiguration` resource and pass to the K8S api server path to this file `--encryption-provider-config`
        ```
        apiVersion: apiserver.config.k8s.io/v1
        kind: EncryptionConfiguration
        resources:
        - resources:
            - secrets
            providers:
            - aesgcm:
                keys:
                - name: key1
                secret: c2VjcmV0IGlzIHNlY3VyZQ==
                - name: key2
                secret: dGhpcyBpcyBwYXNzd29yZA==
            - aescbc:
                keys:
                - name: key1
                secret: c2VjcmV0IGlzIHNlY3VyZQ==
                - name: key2
                secret: dGhpcyBpcyBwYXNzd29yZA==
            - secretbox:
                keys:
                - name: key1
                secret: YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY=
            - identity: {} - used for read all secret
        ```
    1. First one used for encription on save
    
    1. Encrypt secrets in ETCD at rest
        1. Create directory to store `EncryptionConfiguration`
            ```
            cd /etc/kubernetes
            mkdir etcd
            ```
        1. Create `EncryptionConfiguration`
            ```
            vi ec.yaml

            apiVersion: apiserver.config.k8s.io/v1
            kind: EncryptionConfiguration
            resources:
            - resources:
            - secrets
            providers:
            - aescbc:
                keys:
                - name: key1
                secret: cGFzc3dvcmQ=
            - identity: {}

            ```
        1. Mount `EncryptionConfiguration` in K8s api server
        1. New secrets should be encrypted in etcd. Old passwords wan't be encrypted
        1. When we read secret via API it's not encrypted
        1. Without `- identity: {}` K8s api server can't get secrets
        1. To recreate all secrets and encrypt them:
            ```
            kubectl get secret -A -o yaml | kubectl replace -f -
            ```
        1. Then we can remove `- identity: {}`

        
