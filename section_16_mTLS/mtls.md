# mTLS - Mutual TLS

1. Mutual authentication
1. Two-way authentication
1. Two parties authenticating each other at the same time

# K8s Pod to Pod communication

1. By default all pods can communicate each other
1. If traffic between pods is encripted then attacer can't decrypt it

# Implement mTLS between pods

1. One pod has client cert
1. Second pod need server cert
1. certificates are signed by the same CA
1. We need to rotate certificates

# ServiceMesh/Proxy

1. Proxy container managed all required mTLS steps (sidecar container)
1. Proxy container can be managed externally
1. To force traffic via proxy iptables rules to route traffic via proxy need to by created. It can be done in initContainer a nd needs NET_ADMIN capability

1. Create sidecar container
    ```
    kubectl run app --image=bash --command -o yaml --dry-run=client  > app.yaml -- sh -c 'ping google.com'
    ```     