# Create VM
1.  Two VM will be created on Virtualbox using vagrant

    ```
    $ vagrant up
    ```
1. Access each VM and install K8s packages
    1. Log in to `kubemaster`
    1. Run `install_master.sh`
        ```
        $ vagrant ssh kubemaster
        $ sudo -i
        # cd /home/vagrant/cks/ubuntu
        ./install_master.sh
        ```
    1. Get command to join worker node to the cluster and remember output to run it later on worker node

        ```
        # kubeadm token create --print-join-command --ttl 0
        ```

    1. Log in to `kubenode`
    1. Run `install_worker.sh`
        ```
        $ vagrant ssh kubenode
        $ sudo -i
        # cd /home/vagrant/cks/ubuntu
        ./install_worker.sh
        ```
    1. Run command from step 3. to join worker to the cluster
