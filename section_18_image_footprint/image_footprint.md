# Docker containers

1. Each docker container have layers
1. Only instructions RUN, COPY and ADD creates new layer

# Reduce image footprint via Multi-Stage build

1. Resources: 
    
    * https://github.com/killer-sh/cks-course-environment/tree/master/course-content/supply-chain-security/image-footprint
    * https://docs.docker.com/develop/develop-images/dockerfile_best-practices

1. Secure and hardening images
    1. Use image/packages versions
    1. Don't use as root
    1. Make filesystem read only
    1. Remove shell access
