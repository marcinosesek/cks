# Network policies 

* Are Firewall rules in kubernetes
* Implemented by Network Plugins CNI (Calico/Weave)
* Namespace level
* Restrict the Ingres and/or Egress for group of Pods
* By default every pod can access every pods - pods are not isolated
* By default pods can access GCP metadata server - it should be blocked by netpol by default and only speecifica pods should have access to this server

# Resources

    https://kubernetes.io/docs/concepts/services-networking/network-policies