# Reduce Attack Surface

1. Application
    * Keep up to data
    * Update Linux Kernel
    * Remove not needed packages
1. Network
    * Network behind firewall
    * Check and close open ports
1. IAM
    * Restrict user permissions
    * Run as user, not root

1. Nodes that run Kubernetes
    * only purpose: run K8s components
    * remove unnecessary services
1. Node Recycling
    * nodes should be ephemeral
    * creted from images
    * can be recycled any time (and fast if necessary)

1. Commands
    1. Open ports: 
        * `netstat -plnt| grep 22`
        * `lsof -i :22`
    1. Running services
        * `systemctl status <service name>`
        * `systemctl list-units --type=service --state=running | grep sshd`
    1. Processes and users
        * `ps aux`
        * `cat /etc/passwd`