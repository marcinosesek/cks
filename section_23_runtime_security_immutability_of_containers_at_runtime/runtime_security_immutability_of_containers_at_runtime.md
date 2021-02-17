# Immutability of containers at runtime

1. Immutability means that containers wan't be modified during it's lifetime

1. Mutable means:
    * We can ssh to VM/Container instance
    * Stop application
    * Update application
    * Start application

1. Immutable means:
    * Create new VM/Container image
    * Delete VM/Container instance
    * Crete new VM/Container instance
    * We always know the state !!!
    * Advanced deployment method
    * Easy rollback
    * More reliability
    * Better security (on container level)

1. To ensure that our continers are immutable:
    * remove bash/shell
    * make filesystem read-only
    * run as user and non root

1. StartupProbe
    * No readiness/liveness proble will be executed until startup probl will be completed
    * We can remove some binaries at startup in startupProbe section
        ```
        kubectl apply -f immutable.yaml
        ```

1. Enforce read-only root filesystem using SecurityContexts and PSP
    ```
    kubectl apply -f immutable_read_only_filesystem.yaml
    ```
1. Move logic to initcontainers
    * Containers can communicate using volumes
    * init container can Read-Write to volume and app containers only read

1. With RBAC we should be sure that only specific person can edit pods
