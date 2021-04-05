# Sample questions

1. You have access to multiple clusters from your main terminal through kubectl contexts. 
   1. Write all context names into /opt/course/1/contexts, one per line. 
   1. From the kubeconfig extract the certificate of user restricted@infra-prod and write it decoded to /opt/course/1/cert.

1. Falco is installed with default configuration on node cluster1-worker1. Connect using ssh cluster1-worker1. Use it to:
   1. Find a Pod running image nginx which creates unwanted package management processes inside its container.
   1. Find a Pod running image httpd which modifies /etc/passwd.
   1. Save the Falco logs for case 1 under /opt/course/2/falco.log in format time,container-id,container-name,user-name. No other information should be in any line. Collect the logs for at least 30 seconds.
   1. Afterwards remove the threads (both 1 and 2) by scaling the replicas of the Deployments that control the offending Pods down to 0.

1. You received a list from the DevSecOps team which performed a security investigation of the k8s cluster1 (workload-prod). The list states the following about the apiserver setup:
   1. Anonymous access is allowed
   1. It's accessible on insecure port 8080
   1. it's accessible through a NodePort Service

   1. Change the apiserver setup so that:
      1. No anonymous access is allowed
      1. It's only accessible over HTTPS (disable insecure access)
      1. It's only accessible through a ClusterIP Service

1. There is Deployment docker-log-hacker in Namespace team-red which mounts /var/lib/docker as a hostPath volume on the Node where its running. This means that the Pods can for example read all Docker container logs which are running on the same Node.

   1. You're asked to forbid this behavior by:
      1. Enabling Admission Plugin PodSecurityPolicy in the apiserver
      1. Creating a PodSecurityPolicy named psp-mount which allows hostPath volumes only for directory /tmp
      1. Creating a ClusterRole named psp-mount which allows to use the new PSP
      1. Creating a RoleBinding named psp-mount in Namespace team-red which binds the new ClusterRole to all ServiceAccounts in the Namespace team-red
      1. Restart the Pod of Deployment docker-log-hacker afterwards to verify new creation is prevented.
      1. PSPs can affect the whole cluster. Should you encounter issues you can always disable the Admission Plugin again.