kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

echo "
spec:
  type: NodePort
  ports:
  - targetPort: 9090
    port: 443
    protocol: TCP

" > patch-svc.yaml

kubectl patch svc -n kubernetes-dashboard kubernetes-dashboard --type merge --patch "$(cat patch-svc.yaml)"

echo "
spec:
  template:
    spec:
      containers:
      - args:
        - --namespace=kubernetes-dashboard
        - --enable-skip-login=true
        - --enable-insecure-login=true
        - --authentication-mode=basic
        - --insecure-port=9090
        - --api-log-level=DEBUG
        image: kubernetesui/dashboard:v2.0.0
        imagePullPolicy: Always
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /
            port: 9090
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 30
        name: kubernetes-dashboard
        ports:
        - containerPort: 9090
          protocol: TCP
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsGroup: 2001
          runAsUser: 1001
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /certs
          name: kubernetes-dashboard-certs
        - mountPath: /tmp
          name: tmp-volume

" > patch-deployment.yaml

kubectl patch deploy -n kubernetes-dashboard kubernetes-dashboard --type merge --patch "$(cat patch-deployment.yaml)"

