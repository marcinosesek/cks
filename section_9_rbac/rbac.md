# RBAC

1. Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within your organization

1. `kube-apiserver` it's enabled with --authorization-mode - by default it's always allow
1. We always specify what is allowed with RBAC there is no way to deny
1. Resources:
    1. namespaces
        ```
        kubectl api-resources --namespaced=true
        ```
    1. non namespaced
        ```
        kubectl api-resources --namespaced=false
        ```
1. Roles/ClusterRole
    * set of permissions
        * can edit pods
        * can read secrets
    * roles are specific for namespace
    * clusterrole are in all namespaces

1. RoleBinding/ClusterRoleBinding
    * who gets a set of permissions
        * bind Role/ClusterRole to something
    * rolebinding specifies who can do what in namespace
    * clusterroles specifies who can do what in all namespaces

1. ClusterRole/ClusterRoleBinding - they apply to all current and future namespaces and non namespaced resources

1. Role can be 
    * combined with rolebinding
    * We can't combined role with ClusterRoleBinding

1. ClusterRole can be
    * combined with ClusterRoleBinding
    * combined with RoleBinding

1. Permissions are additive
1. Always test your RBAC rules!!

1. Test roles

    ```
    kubectl create role secret-manager --verb=get,list --resource=secret -n blue -o yaml --dry-run=client
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    creationTimestamp: null
    name: secret-manager
    namespace: blue
    rules:
    - apiGroups:
    - ""
    resources:
    - secrets
    verbs:
    - get
    - list
    ```

    ```
    kubectl auth can-i -n red get secrets --as jane
    ```

    ```
    kubectl create clusterrolebinding  deploy-deleter --clusterrole=deploy-deleter --user=jane
    clusterrolebinding.rbac.authorization.k8s.io/deploy-deleter created
    ```
    
    ```
    kubectl  create rolebinding deploy-deleter --clusterrole=deploy-deleter -n red --user=jim
    rolebinding.rbac.authorization.k8s.io/deploy-deleter created
    ```

1. Accounts
    * serviceaccounts - resources managed by k8s api
    * users - there is no user resources in k8s - cluster-independent service manages normal users. 
        * It's someone with cert and key
        * client cert signed by cluster's CA
        * username under common name: /CN=jane

1. CertificateSigningRequest
    * created in CSR resource
    * K8s Api server sign CSR and put it in CSR
    * We can get CRT from CSR
    * There is not way to invalidate a certificate
    * If a certificate has been leaked
        * Remove all access via RBAC
        * Username can't be used until cert expires
        * Create new CA and re-issue all certs

1. Allow access to the user
    1. Create certificate and key
        ```
        openssl genrsa -out jane.key 2048
        ```

        ```
        openssl req -new -key jane.key -out jane.csr
        openssl req -new -key jane.key -out jane.csr
        Can't load /root/.rnd into RNG
        139735029432768:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:88:Filename=/root/.rnd
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
        Common Name (e.g. server FQDN or YOUR name) []:jane
        Email Address []:

        Please enter the following 'extra' attributes
        to be sent with your certificate request
        A challenge password []:
        An optional company name []:
        ```

    1. Create CSR

        ```
        cat jane.csr | base64 -w 0
        LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ21UQ0NBWUVDQVFBd1ZERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApJVEFmQmdOVkJBb01HRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERU5NQXNHQTFVRUF3d0VhbUZ1ClpUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUpjNDJ6N2ZmNnZ1RitlaVhBMXEKVnZFR3poYy9nNTRMbWxoTkZvM29Iek9FSlJLbHFPM0c5WVpraWE1b3FNMldsWkp6aHRzOGFUczVWbTlTMFN6UQp0bnFRZW9MQnpvNkkrRkJiS3BrY0k5REhWWW55ZTZVWjVOZmlQRERlNTFMN00zRGVFT1BuWGZVc3JsNk03ODdOCjFWWUhSR25jU1pIaHBtZHhJRTRvdTVMcG5QcTZjS2tCUXEvS2RtTGthbCtLM21xS2c2cnJ2b050Vm5HMGcwUTQKMGJMNmZnOUhhSkZNZTBFSGFrU1BCUTFkclRxQW1yZE1YaUd6dkRDMmsrL2JyZGJIMW83RFVndzQ3OGhTY1ZLRgp1NmFKMzhWV0RlZ25URTk3NlYyT1FBY3BzUmVYVWo0MTZuNUZNVjIrVFRia2h0R0NyRlBUSmxENE9mOUd5ekpuCnVDc0NBd0VBQWFBQU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQTFrTkdJR01NNFUvMUUrYlRrRUFjRnZyejIKV3NYY0RpYXBnVXY2cEpjWlZNRmMrWkY0MUt5Q3ZjSnNzQW5adjNXdURFQXVYV2RNZlpNV1AwL2lta1kzcmp3aAprdzYzRkdvMTdRTTNWZW56L3NrTXpLakNYd1cvaElVRUtuUmptZlRja3FXcHU5TzRHMHZmMm85VmFvcTZ2WTFrCkFDTy9yZFJNdXhYWGIxK3huVzlraEsrQ3Y2RGtYV1VyQ1d2WTRndEp0TzBHWUpBWHlKdWdEeXdVVndicDNqWDMKZWlQQkZoUWpqQ3J1TlhsYzVHdkhRY3dMVlE3UHYrUVFGNllNbVlYT3M5bE91UGRuTDNrTGpjNnpoREw1ZEp4TApUZlhSTHFkWEQrZkVWeW9senM0aWZqKy9LTFF2a1pGd0hZTU44SFVYazZWZ1V4TUl4MDFWNHVjQ3Rsd24KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
        ```

        ```
        cat csr.yaml
        apiVersion: certificates.k8s.io/v1
        kind: CertificateSigningRequest
        metadata:
        name: jane
        spec:
        groups:
        - system:authenticated
        request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ21UQ0NBWUVDQVFBd1ZERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApJVEFmQmdOVkJBb01HRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERU5NQXNHQTFVRUF3d0VhbUZ1ClpUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUpjNDJ6N2ZmNnZ1RitlaVhBMXEKVnZFR3poYy9nNTRMbWxoTkZvM29Iek9FSlJLbHFPM0c5WVpraWE1b3FNMldsWkp6aHRzOGFUczVWbTlTMFN6UQp0bnFRZW9MQnpvNkkrRkJiS3BrY0k5REhWWW55ZTZVWjVOZmlQRERlNTFMN00zRGVFT1BuWGZVc3JsNk03ODdOCjFWWUhSR25jU1pIaHBtZHhJRTRvdTVMcG5QcTZjS2tCUXEvS2RtTGthbCtLM21xS2c2cnJ2b050Vm5HMGcwUTQKMGJMNmZnOUhhSkZNZTBFSGFrU1BCUTFkclRxQW1yZE1YaUd6dkRDMmsrL2JyZGJIMW83RFVndzQ3OGhTY1ZLRgp1NmFKMzhWV0RlZ25URTk3NlYyT1FBY3BzUmVYVWo0MTZuNUZNVjIrVFRia2h0R0NyRlBUSmxENE9mOUd5ekpuCnVDc0NBd0VBQWFBQU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQTFrTkdJR01NNFUvMUUrYlRrRUFjRnZyejIKV3NYY0RpYXBnVXY2cEpjWlZNRmMrWkY0MUt5Q3ZjSnNzQW5adjNXdURFQXVYV2RNZlpNV1AwL2lta1kzcmp3aAprdzYzRkdvMTdRTTNWZW56L3NrTXpLakNYd1cvaElVRUtuUmptZlRja3FXcHU5TzRHMHZmMm85VmFvcTZ2WTFrCkFDTy9yZFJNdXhYWGIxK3huVzlraEsrQ3Y2RGtYV1VyQ1d2WTRndEp0TzBHWUpBWHlKdWdEeXdVVndicDNqWDMKZWlQQkZoUWpqQ3J1TlhsYzVHdkhRY3dMVlE3UHYrUVFGNllNbVlYT3M5bE91UGRuTDNrTGpjNnpoREw1ZEp4TApUZlhSTHFkWEQrZkVWeW9senM0aWZqKy9LTFF2a1pGd0hZTU44SFVYazZWZ1V4TUl4MDFWNHVjQ3Rsd24KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
        signerName: kubernetes.io/kube-apiserver-client
        usages:
        - client auth
        ```
    
        ```
        kubectl apply -f csr.yaml 
        certificatesigningrequest.certificates.k8s.io/jane created
        ```

        ```
        kubectl get csr
        NAME   AGE   SIGNERNAME                            REQUESTOR          CONDITION
        jane   29s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Pending
        ```
    
    1. Approve CSR
        ```
        kubectl certificate approve jane
        certificatesigningrequest.certificates.k8s.io/jane approved
        kubectl get csr
        NAME   AGE   SIGNERNAME                            REQUESTOR          CONDITION
        jane   85s   kubernetes.io/kube-apiserver-client   kubernetes-admin   Approved,Issued
        ```
        ```
        kubectl  get csr jane -o yaml
        apiVersion: certificates.k8s.io/v1
        kind: CertificateSigningRequest
        metadata:
        annotations:
            kubectl.kubernetes.io/last-applied-configuration: |
            {"apiVersion":"certificates.k8s.io/v1","kind":"CertificateSigningRequest","metadata":{"annotations":{},"name":"jane"},"spec":{"groups":["system:authenticated"],"request":"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ21UQ0NBWUVDQVFBd1ZERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApJVEFmQmdOVkJBb01HRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERU5NQXNHQTFVRUF3d0VhbUZ1ClpUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUpjNDJ6N2ZmNnZ1RitlaVhBMXEKVnZFR3poYy9nNTRMbWxoTkZvM29Iek9FSlJLbHFPM0c5WVpraWE1b3FNMldsWkp6aHRzOGFUczVWbTlTMFN6UQp0bnFRZW9MQnpvNkkrRkJiS3BrY0k5REhWWW55ZTZVWjVOZmlQRERlNTFMN00zRGVFT1BuWGZVc3JsNk03ODdOCjFWWUhSR25jU1pIaHBtZHhJRTRvdTVMcG5QcTZjS2tCUXEvS2RtTGthbCtLM21xS2c2cnJ2b050Vm5HMGcwUTQKMGJMNmZnOUhhSkZNZTBFSGFrU1BCUTFkclRxQW1yZE1YaUd6dkRDMmsrL2JyZGJIMW83RFVndzQ3OGhTY1ZLRgp1NmFKMzhWV0RlZ25URTk3NlYyT1FBY3BzUmVYVWo0MTZuNUZNVjIrVFRia2h0R0NyRlBUSmxENE9mOUd5ekpuCnVDc0NBd0VBQWFBQU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQTFrTkdJR01NNFUvMUUrYlRrRUFjRnZyejIKV3NYY0RpYXBnVXY2cEpjWlZNRmMrWkY0MUt5Q3ZjSnNzQW5adjNXdURFQXVYV2RNZlpNV1AwL2lta1kzcmp3aAprdzYzRkdvMTdRTTNWZW56L3NrTXpLakNYd1cvaElVRUtuUmptZlRja3FXcHU5TzRHMHZmMm85VmFvcTZ2WTFrCkFDTy9yZFJNdXhYWGIxK3huVzlraEsrQ3Y2RGtYV1VyQ1d2WTRndEp0TzBHWUpBWHlKdWdEeXdVVndicDNqWDMKZWlQQkZoUWpqQ3J1TlhsYzVHdkhRY3dMVlE3UHYrUVFGNllNbVlYT3M5bE91UGRuTDNrTGpjNnpoREw1ZEp4TApUZlhSTHFkWEQrZkVWeW9senM0aWZqKy9LTFF2a1pGd0hZTU44SFVYazZWZ1V4TUl4MDFWNHVjQ3Rsd24KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==","signerName":"kubernetes.io/kube-apiserver-client","usages":["client auth"]}}
        creationTimestamp: "2021-02-04T22:09:57Z"
        managedFields:
        - apiVersion: certificates.k8s.io/v1
            fieldsType: FieldsV1
            fieldsV1:
            f:metadata:
                f:annotations:
                .: {}
                f:kubectl.kubernetes.io/last-applied-configuration: {}
            f:spec:
                f:groups: {}
                f:request: {}
                f:signerName: {}
                f:usages: {}
            manager: kubectl-client-side-apply
            operation: Update
            time: "2021-02-04T22:09:57Z"
        - apiVersion: certificates.k8s.io/v1
            fieldsType: FieldsV1
            fieldsV1:
            f:status:
                f:certificate: {}
            manager: kube-controller-manager
            operation: Update
            time: "2021-02-04T22:11:15Z"
        - apiVersion: certificates.k8s.io/v1
            fieldsType: FieldsV1
            fieldsV1:
            f:status:
                f:conditions:
                .: {}
                k:{"type":"Approved"}:
                    .: {}
                    f:lastTransitionTime: {}
                    f:lastUpdateTime: {}
                    f:message: {}
                    f:reason: {}
                    f:status: {}
                    f:type: {}
            manager: kubectl
            operation: Update
            time: "2021-02-04T22:11:15Z"
        name: jane
        resourceVersion: "40130"
        uid: aab04951-ce4d-4a31-ad12-f277a7c76aac
        spec:
        groups:
        - system:masters
        - system:authenticated
        request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ21UQ0NBWUVDQVFBd1ZERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApJVEFmQmdOVkJBb01HRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERU5NQXNHQTFVRUF3d0VhbUZ1ClpUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUpjNDJ6N2ZmNnZ1RitlaVhBMXEKVnZFR3poYy9nNTRMbWxoTkZvM29Iek9FSlJLbHFPM0c5WVpraWE1b3FNMldsWkp6aHRzOGFUczVWbTlTMFN6UQp0bnFRZW9MQnpvNkkrRkJiS3BrY0k5REhWWW55ZTZVWjVOZmlQRERlNTFMN00zRGVFT1BuWGZVc3JsNk03ODdOCjFWWUhSR25jU1pIaHBtZHhJRTRvdTVMcG5QcTZjS2tCUXEvS2RtTGthbCtLM21xS2c2cnJ2b050Vm5HMGcwUTQKMGJMNmZnOUhhSkZNZTBFSGFrU1BCUTFkclRxQW1yZE1YaUd6dkRDMmsrL2JyZGJIMW83RFVndzQ3OGhTY1ZLRgp1NmFKMzhWV0RlZ25URTk3NlYyT1FBY3BzUmVYVWo0MTZuNUZNVjIrVFRia2h0R0NyRlBUSmxENE9mOUd5ekpuCnVDc0NBd0VBQWFBQU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQTFrTkdJR01NNFUvMUUrYlRrRUFjRnZyejIKV3NYY0RpYXBnVXY2cEpjWlZNRmMrWkY0MUt5Q3ZjSnNzQW5adjNXdURFQXVYV2RNZlpNV1AwL2lta1kzcmp3aAprdzYzRkdvMTdRTTNWZW56L3NrTXpLakNYd1cvaElVRUtuUmptZlRja3FXcHU5TzRHMHZmMm85VmFvcTZ2WTFrCkFDTy9yZFJNdXhYWGIxK3huVzlraEsrQ3Y2RGtYV1VyQ1d2WTRndEp0TzBHWUpBWHlKdWdEeXdVVndicDNqWDMKZWlQQkZoUWpqQ3J1TlhsYzVHdkhRY3dMVlE3UHYrUVFGNllNbVlYT3M5bE91UGRuTDNrTGpjNnpoREw1ZEp4TApUZlhSTHFkWEQrZkVWeW9senM0aWZqKy9LTFF2a1pGd0hZTU44SFVYazZWZ1V4TUl4MDFWNHVjQ3Rsd24KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
        signerName: kubernetes.io/kube-apiserver-client
        usages:
        - client auth
        username: kubernetes-admin
        status:
        certificate: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURPVENDQWlHZ0F3SUJBZ0lRSjdmS281VHNobDl4UGVqczlzblRoVEFOQmdrcWhraUc5dzBCQVFzRkFEQVYKTVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1CNFhEVEl4TURJd05ESXlNRFl4TlZvWERUSXlNREl3TkRJeQpNRFl4TlZvd1ZERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdUQ2xOdmJXVXRVM1JoZEdVeElUQWZCZ05WCkJBb1RHRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERU5NQXNHQTFVRUF4TUVhbUZ1WlRDQ0FTSXcKRFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUpjNDJ6N2ZmNnZ1RitlaVhBMXFWdkVHemhjLwpnNTRMbWxoTkZvM29Iek9FSlJLbHFPM0c5WVpraWE1b3FNMldsWkp6aHRzOGFUczVWbTlTMFN6UXRucVFlb0xCCnpvNkkrRkJiS3BrY0k5REhWWW55ZTZVWjVOZmlQRERlNTFMN00zRGVFT1BuWGZVc3JsNk03ODdOMVZZSFJHbmMKU1pIaHBtZHhJRTRvdTVMcG5QcTZjS2tCUXEvS2RtTGthbCtLM21xS2c2cnJ2b050Vm5HMGcwUTQwYkw2Zmc5SAphSkZNZTBFSGFrU1BCUTFkclRxQW1yZE1YaUd6dkRDMmsrL2JyZGJIMW83RFVndzQ3OGhTY1ZLRnU2YUozOFZXCkRlZ25URTk3NlYyT1FBY3BzUmVYVWo0MTZuNUZNVjIrVFRia2h0R0NyRlBUSmxENE9mOUd5ekpudUNzQ0F3RUEKQWFOR01FUXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUhBd0l3REFZRFZSMFRBUUgvQkFJd0FEQWZCZ05WSFNNRQpHREFXZ0JUbkUzQ1NRdE0rQkdVdFVaaWpXSCtFN09tSzNEQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFSU3g4CkdwOVM5UHZyOXhSbjRNMzRqNHYrUlY3Ykpjam9ybUJIazNKY0ovV0E2bFAzTE82bDRIOE9iQXNyZEJVd1llYm0KNnk1OWRLNlNjS2RDeEM4aUlIRDNqL1hGUk9LL2lQam15Z0NJODJDRkZlWTVqem1zanlhcUdBS2FZSDF3NmRaSwpKSjdXdTE0SEdWZTdHeENpeEZxTUxOSmFWRGVIVUd3SXZVY2YwZVZSU05FMmprZHYwMWsrbmhoZmsxQWlWTmJRCm8xcFgwcm9yZjVCeWhMaFVSUlZiaTJLTjdUUFkwb1EzQk1uYXJpMGo5WnFuRFZUUjdoZ2hXTmRYUC9WZjY4MkgKYWk2eXF5c3Zlc3hCWVhHMEcvb2p5cXlTMWgxMTBodUJ0a0c0Tm1hWDN3bFFLaDJpdlBqV3FTcGJwN3pHM3hHNQpocGZyMFNyMmVKbWcwSG01dXc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
        conditions:
        - lastTransitionTime: "2021-02-04T22:11:15Z"
            lastUpdateTime: "2021-02-04T22:11:15Z"
            message: This CSR was approved by kubectl certificate approve.
            reason: KubectlApprove
            status: "True"
            type: Approved
        ```

    1. Download CRT from API
        ```
        echo LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURPVENDQWlHZ0F3SUJBZ0lRSjdmS281VHNobDl4UGVqczlzblRoVEFOQmdrcWhraUc5dzBCQVFzRkFEQVYKTVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1CNFhEVEl4TURJd05ESXlNRFl4TlZvWERUSXlNREl3TkRJeQpNRFl4TlZvd1ZERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdUQ2xOdmJXVXRVM1JoZEdVeElUQWZCZ05WCkJBb1RHRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERU5NQXNHQTFVRUF4TUVhbUZ1WlRDQ0FTSXcKRFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUpjNDJ6N2ZmNnZ1RitlaVhBMXFWdkVHemhjLwpnNTRMbWxoTkZvM29Iek9FSlJLbHFPM0c5WVpraWE1b3FNMldsWkp6aHRzOGFUczVWbTlTMFN6UXRucVFlb0xCCnpvNkkrRkJiS3BrY0k5REhWWW55ZTZVWjVOZmlQRERlNTFMN00zRGVFT1BuWGZVc3JsNk03ODdOMVZZSFJHbmMKU1pIaHBtZHhJRTRvdTVMcG5QcTZjS2tCUXEvS2RtTGthbCtLM21xS2c2cnJ2b050Vm5HMGcwUTQwYkw2Zmc5SAphSkZNZTBFSGFrU1BCUTFkclRxQW1yZE1YaUd6dkRDMmsrL2JyZGJIMW83RFVndzQ3OGhTY1ZLRnU2YUozOFZXCkRlZ25URTk3NlYyT1FBY3BzUmVYVWo0MTZuNUZNVjIrVFRia2h0R0NyRlBUSmxENE9mOUd5ekpudUNzQ0F3RUEKQWFOR01FUXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUhBd0l3REFZRFZSMFRBUUgvQkFJd0FEQWZCZ05WSFNNRQpHREFXZ0JUbkUzQ1NRdE0rQkdVdFVaaWpXSCtFN09tSzNEQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFSU3g4CkdwOVM5UHZyOXhSbjRNMzRqNHYrUlY3Ykpjam9ybUJIazNKY0ovV0E2bFAzTE82bDRIOE9iQXNyZEJVd1llYm0KNnk1OWRLNlNjS2RDeEM4aUlIRDNqL1hGUk9LL2lQam15Z0NJODJDRkZlWTVqem1zanlhcUdBS2FZSDF3NmRaSwpKSjdXdTE0SEdWZTdHeENpeEZxTUxOSmFWRGVIVUd3SXZVY2YwZVZSU05FMmprZHYwMWsrbmhoZmsxQWlWTmJRCm8xcFgwcm9yZjVCeWhMaFVSUlZiaTJLTjdUUFkwb1EzQk1uYXJpMGo5WnFuRFZUUjdoZ2hXTmRYUC9WZjY4MkgKYWk2eXF5c3Zlc3hCWVhHMEcvb2p5cXlTMWgxMTBodUJ0a0c0Tm1hWDN3bFFLaDJpdlBqV3FTcGJwN3pHM3hHNQpocGZyMFNyMmVKbWcwSG01dXc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg== | base64 -d > jane.crt
        ```

    1. User CRT and KEY

        ```
        kubectl config view
        apiVersion: v1
        clusters:
        - cluster:
            certificate-authority-data: DATA+OMITTED
            server: https://192.168.56.2:6443
        name: kubernetes
        contexts:
        - context:
            cluster: kubernetes
            user: kubernetes-admin
        name: kubernetes-admin@kubernetes
        current-context: kubernetes-admin@kubernetes
        kind: Config
        preferences: {}
        users:
        - name: kubernetes-admin
        user:
            client-certificate-data: REDACTED
            client-key-data: REDACTED
        ```

        ```
        kubectl config set-credentials jane --client-key=jane.key --client-certificate=jane.crt --embed-certs=true
        User "jane" set.
        ```

        ```
        kubectl config viewapiVersion: v1
        clusters:
        - cluster:
            certificate-authority-data: DATA+OMITTED
            server: https://192.168.56.2:6443
        name: kubernetes
        contexts:
        - context:
            cluster: kubernetes
            user: kubernetes-admin
        name: kubernetes-admin@kubernetes
        current-context: kubernetes-admin@kubernetes
        kind: Config
        preferences: {}
        users:
        - name: jane
        user:
            client-certificate-data: REDACTED
            client-key-data: REDACTED
        - name: kubernetes-admin
        user:
            client-certificate-data: REDACTED
            client-key-data: REDACTED
        ```

        ```
        kubectl config set-context jane --cluster=kubernetes --user=jane
        ```

        ```
        kubectl config get-contexts 
        CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
                  jane                          kubernetes   jane               
        *         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin 
        ```

        ```
        kubectl config use-context jane
        ```

        ```
        kubectl get ns
        Error from server (Forbidden): namespaces is forbidden: User "jane" cannot list resource "namespaces" in API group "" at the cluster scope
        ```

        ```
        kubectl get secrets -n blue
        NAME                  TYPE                                  DATA   AGE
        default-token-w6c4s   kubernetes.io/service-account-token   3      46m
        ```

        ```
        kubectl auth can-i delete deployments -A
        yes
        ```