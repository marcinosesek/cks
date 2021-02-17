# K8s and container registries

1. Access to private registries:
    1. Need to create secret of type `docker-registry`
    1. Update service account and add `imagePullSecret`

# Use Image Digest

1. List all used images
    ```
    root@kubemaster:~# kubectl get po -A -o yaml | grep image: | grep -v 'f:'
    image: k8s.gcr.io/coredns:1.7.0
    image: k8s.gcr.io/coredns:1.7.0
    image: k8s.gcr.io/coredns:1.7.0
    image: k8s.gcr.io/coredns:1.7.0
    image: k8s.gcr.io/etcd:3.4.13-0
    image: k8s.gcr.io/etcd:3.4.13-0
    image: k8s.gcr.io/kube-apiserver:v1.20.2
    image: k8s.gcr.io/kube-apiserver:v1.20.2
    image: k8s.gcr.io/kube-controller-manager:v1.20.2
    image: k8s.gcr.io/kube-controller-manager:v1.20.2
    image: k8s.gcr.io/kube-proxy:v1.20.2
    image: k8s.gcr.io/kube-proxy:v1.20.2
    image: k8s.gcr.io/kube-proxy:v1.20.2
    image: k8s.gcr.io/kube-proxy:v1.20.2
    image: k8s.gcr.io/kube-scheduler:v1.20.2
    image: k8s.gcr.io/kube-scheduler:v1.20.2
    image: docker.io/weaveworks/weave-kube:2.8.1
    image: docker.io/weaveworks/weave-npc:2.8.1
    image: docker.io/weaveworks/weave-kube:2.8.1
    image: weaveworks/weave-kube:2.8.1
    image: weaveworks/weave-npc:2.8.1
    image: weaveworks/weave-kube:2.8.1
    image: docker.io/weaveworks/weave-kube:2.8.1
    image: docker.io/weaveworks/weave-npc:2.8.1
    image: docker.io/weaveworks/weave-kube:2.8.1
    image: weaveworks/weave-kube:2.8.1
    image: weaveworks/weave-npc:2.8.1
    image: weaveworks/weave-kube:2.8.1
    ```

1. Check image digest of pod
    ```
    kubectl get po -n kube-system kube-apiserver-kubemaster -o yaml | grep imageID
        image: k8s.gcr.io/kube-apiserver:v1.20.2
        imagePullPolicy: IfNotPresent
        image: k8s.gcr.io/kube-apiserver:v1.20.2
        imageID: docker-pullable://k8s.gcr.io/kube-apiserver@sha256:465ba895d578fbc1c6e299e45689381fd01c54400beba9e8f1d7456077411411
    ```

1. We can use image digest instead of image name. to do it we can replace image with imageID. It's more secured because image tage tag can be overwritten
    ```
    vi /etc/kubernetes/manifests/kube-apiserver.yaml 
    replace: 
        image: k8s.gcr.io/kube-apiserver:v1.20.2
    to: 
        docker-pullable://k8s.gcr.io/kube-apiserver@sha256:465ba895d578fbc1c6e299e45689381fd01c54400beba9e8f1d7456077411411
    ```

# Whitelist registries with OPA

1. Install opa
    ```
    kubectl create -f https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/course-content/opa/gatekeeper.yaml

    ```

1. Create OPA resources

    1. Link to resource:
    
        ```
        https://github.com/killer-sh/cks-course-environment/tree/master/course-content/supply-chain-security/secure-the-supply-chain/whitelist-registries/opa
        ```

    1. Create ConstraintTemplate
        ```
        apiVersion: templates.gatekeeper.sh/v1beta1
        kind: ConstraintTemplate
        metadata:
        name: k8strustedimages
        spec:
        crd:
            spec:
            names:
                kind: K8sTrustedImages
        targets:
            - target: admission.k8s.gatekeeper.sh
            rego: |
                package k8strustedimages
                violation[{"msg": msg}] {
                image := input.review.object.spec.containers[_].image
                not startswith(image, "docker.io/")
                not startswith(image, "k8s.gcr.io/")
                msg := "not trusted image!"
                }
        ```

    1. Create constraints

        ```
        apiVersion: constraints.gatekeeper.sh/v1beta1
        kind: K8sTrustedImages
        metadata:
        name: pod-trusted-images
        spec:
        match:
            kinds:
            - apiGroups: [""]
                kinds: ["Pod"]
        ```

    1. OPA template allows to create pods that uses images from `docker.io/` or `k8s.gcr.io/` registries. Image should start with these repositories names

    # ImagePullWebhook

    1. To enable `ImagePullWebhook` we need to edit k8s api server manifest file and add it to `--enable-admission-plugins` parameter and add new parameter with configuration admission-plugin

        ```
        vi /etc/kubernetes/manifests/kube-apiserver.yaml

        ...
        - command:
            - kube-apiserver
            - --advertise-address=192.168.56.2
            - --allow-privileged=true
            - --authorization-mode=Node,RBAC
            - --client-ca-file=/etc/kubernetes/pki/ca.crt
            - --enable-admission-plugins=NodeRestriction,ImagPullWebhook
            - --admision-control-config-file=/etc/kubernetes/admission/admission_config.yaml - add this
        
        ...
          volumeMounts:
          ...
          - mountPath: /etc/kubernetes/admission
          name: k8s-admission
          readOnly: true
        
        ...
        volumes:
        ...
        - hostPath:
            path: /etc/kubernetes/admission
            type: DirectoryOrCreate
            name: k8s-admission
        ```

    1. Pod logs we can find in `/var/log/pods`
        ```
        root@kubemaster:~# cd /var/log/pods/
        root@kubemaster:/var/log/pods# ls -ltra
        total 40
        drwxrwxr-x 10 root syslog 4096 Feb 11 20:58 ..
        drwxr-xr-x  3 root root   4096 Feb 11 20:58 kube-system_kube-scheduler-kubemaster_69cd289b4ed80ced4f95a59ff60fa102
        drwxr-xr-x  3 root root   4096 Feb 11 20:58 kube-system_kube-apiserver-kubemaster_ab00486482074ed154fb8e4a4936d37c
        drwxr-xr-x  3 root root   4096 Feb 11 20:58 kube-system_kube-controller-manager-kubemaster_3456cf17d1057cfffaa60b9ccb6eaf2d
        drwxr-xr-x  3 root root   4096 Feb 11 20:58 kube-system_etcd-kubemaster_0304a8e4a4f16ab5b8e8cf3b847bffea
        drwxr-xr-x  3 root root   4096 Feb 11 20:59 kube-system_kube-proxy-dm2b8_2405987f-20a7-49be-bd72-bc2ab66854e6
        drwxr-xr-x 10 root root   4096 Feb 11 21:00 .
        drwxr-xr-x  5 root root   4096 Feb 11 21:01 kube-system_weave-net-rzc2s_42341380-6d42-4788-b426-9e87d7c82906
        drwxr-xr-x  3 root root   4096 Feb 11 21:01 kube-system_coredns-74ff55c5b-64q6f_5e3373b1-06dd-44ef-8e58-25fd49aa770a
        drwxr-xr-x  3 root root   4096 Feb 11 21:01 kube-system_coredns-74ff55c5b-67fqp_a28bf2ca-b95f-42eb-b707-4b2d83e8563b
        root@kubemaster:/var/log/pods# 
        ```
    1. Resources:
        1. Get example
            ```
            git clone https://github.com/killer-sh/cks-course-environment.git
            cp -r cks-course-environment/course-content/supply-chain-security/secure-the-supply-chain/whitelist-registries/ImagePolicyWebhook/ /etc/kubernetes/admission
            ```
        1. Cluster can refer to the external service when create pods
        1. Example of an external service which can be used
            ```
            https://github.com/flavio/kube-image-bouncer
            ```
    1. After these changes k8s-apiserver pod wan't be visible because addmission webhook prevent to list it

    1. We can create new pods only if external service will respond and allow to do it.