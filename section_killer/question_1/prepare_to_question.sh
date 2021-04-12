for i in {1..2}
do
    USER_NAME="user-${i}"
    cp cert.cnf.tpl cert-${USER_NAME}.cnf
    echo "CN=${USER_NAME}" >> cert-${USER_NAME}.cnf
    openssl genrsa -out ${USER_NAME}.key 2048
    openssl req -new -key ${USER_NAME}.key -out ${USER_NAME}.csr -config cert-${USER_NAME}.cnf
    REQUEST=`cat ${USER_NAME}.csr | base64 | tr -d "\n"`
    echo "
    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
        name: ${USER_NAME}
    spec:
        groups:
        - system:authenticated
        request: ${REQUEST}
        signerName: kubernetes.io/kube-apiserver-client
        usages:
        - client auth
    " > ${USER_NAME}-csr.yaml

    kubectl apply -f ${USER_NAME}-csr.yaml
    kubectl get csr
    kubectl certificate approve ${USER_NAME}
    kubectl get csr

    kubectl get csr ${USER_NAME} -o jsonpath='{.status.certificate}'| base64 -d > ${USER_NAME}.crt

    kubectl config set-credentials ${USER_NAME} --client-key=${USER_NAME}.key --client-certificate=${USER_NAME}.crt --embed-certs=true
    kubectl config set-context ${USER_NAME} --cluster=kubernetes --user=${USER_NAME}

    NAMESPACE=${USER_NAME}-ns
    kubectl create ns ${USER_NAME}-ns
    kubectl create role ${USER_NAME}-developer --verb=create,get,list --resource=deployments,pods -n ${NAMESPACE}
    kubectl create rolebinding ${USER_NAME}-developer-rb --role=${USER_NAME}-developer -n ${NAMESPACE} --user ${USER_NAME}
    kubectl auth can-i get deployments -n ${NAMESPACE} --as ${USER_NAME}

    kubectl get role,rolebinding -n ${NAMESPACE}

done