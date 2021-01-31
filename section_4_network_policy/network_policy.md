# Network policies 
1. Are Firewall rules in kubernetes
1. Implemented by Network Plugins CNI (Calico/Weave)
1. Namespace level
1. Restrict the Ingres and/or Egress for group of Pods
1. By default every pod can access every pods - pods are not isolated
1. By default pods can access GCP metadata server - it should be blocked by netpol by default and only speecifica pods should have access to this server

# Resources
https://kubernetes.io/docs/concepts/services-networking/network-policies