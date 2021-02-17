# Kernel hardening tools

1. To separate `Kernel Space` from `User Space` we can introduce next layer where we use tools like `Seccomp`, `AppArmor`

# AppArmor

1. We can create some kind of shield and allow or deny access to 
    * Filesystem
    * Other processess
    * Networks

1. We need to create `AppArmor profile` 
1. AppArmor profile modes:
    * Unconfined - process can escape
    * Complain - process can escape but it will be logged
    * Enforce - process cannot escape

1. Usefull commands:
    * aa-status - show all profiles
    * aa-genprof - generate new profile
    * aa-complain - put profile in complane mode
    * aa-enforce - put profile in enforce mode
    * aa-logprof - update the profile 

1. Create simple AppArmor profile for curl
    1. Log in to worker node
    1. Curl to outside
        ```
        curl killer.sh -v
        * Rebuilt URL to: killer.sh/
        *   Trying 157.245.26.192...
        * TCP_NODELAY set
        * Connected to killer.sh (157.245.26.192) port 80 (#0)
        > GET / HTTP/1.1
        > Host: killer.sh
        > User-Agent: curl/7.58.0
        > Accept: */*
        > 
        < HTTP/1.1 301 Moved Permanently
        < location: https://killer.sh/
        < date: Mon, 15 Feb 2021 20:40:51 GMT
        < server: istio-envoy
        < content-length: 0
        < 
        * Connection #0 to host killer.sh left intact
        ```
    1. Check AppArmor profiles - It's loaded by default on ubuntu
        ```
        # aa-status 
        apparmor module is loaded.
        16 profiles are loaded.
        16 profiles are in enforce mode.
        /sbin/dhclient
        /usr/bin/lxc-start
        /usr/bin/man
        /usr/lib/NetworkManager/nm-dhcp-client.action
        /usr/lib/NetworkManager/nm-dhcp-helper
        /usr/lib/connman/scripts/dhclient-script
        /usr/lib/snapd/snap-confine
        /usr/lib/snapd/snap-confine//mount-namespace-capture-helper
        /usr/sbin/tcpdump
        docker-default
        lxc-container-default
        lxc-container-default-cgns
        lxc-container-default-with-mounting
        lxc-container-default-with-nesting
        man_filter
        man_groff
        0 profiles are in complain mode.
        20 processes have profiles defined.
        20 processes are in enforce mode.
        docker-default (14497) 
        docker-default (15015) 
        docker-default (15165) 
        docker-default (15196) 
        docker-default (15197) 
        docker-default (15198) 
        docker-default (16356) 
        docker-default (16787) 
        docker-default (16942) 
        docker-default (16943) 
        docker-default (16944) 
        docker-default (17752) 
        docker-default (17807) 
        docker-default (24227) 
        docker-default (24358) 
        docker-default (29832) 
        docker-default (30463) 
        docker-default (30491) 
        docker-default (30492) 
        docker-default (30493) 
        0 processes are in complain mode.
        0 processes are unconfined but have a profile defined.
        ```
    
    1. Install apparmor-utils
        ```
        apt-get install apparmor-utils
        ```
    
    1. Generate new profile for curl
        ```
        aa-genprof curl
        Writing updated profile for /usr/bin/curl.
        Setting /usr/bin/curl to complain mode.

        Before you begin, you may wish to check if a
        profile already exists for the application you
        wish to confine. See the following wiki page for
        more information:
        http://wiki.apparmor.net/index.php/Profiles

        Profiling: /usr/bin/curl

        Please start the application to be profiled in
        another window and exercise its functionality now.

        Once completed, select the "Scan" option below in 
        order to scan the system logs for AppArmor events. 

        For each AppArmor event, you will be given the 
        opportunity to choose whether the access should be 
        allowed or denied.

        [(S)can system log for AppArmor events] / (F)inish
        Setting /usr/bin/curl to enforce mode.

        Reloaded AppArmor profiles in enforce mode.

        Please consider contributing your new profile!
        See the following wiki page for more information:
        http://wiki.apparmor.net/index.php/Profiles

        Finished generating profile for /usr/bin/curl.
        ```
    
    1. Check curl command - it should be prevent
        ```
        curl killer.sh -v
        * Rebuilt URL to: killer.sh/
        * Could not resolve host: killer.sh
        * Closing connection 0
        curl: (6) Could not resolve host: killer.sh
        ```
    
    1. Apparmor profiles are stored in `/etc/apparmor.d/`

    1. To allow curl it's normal work
        ```
        aa-logprof 
        Reading log entries from /var/log/syslog.
        Updating AppArmor profiles in /etc/apparmor.d.
        Enforce-mode changes:

        Profile:  /usr/bin/curl
        Path:     /etc/ssl/openssl.cnf
        New Mode: owner r
        Severity: 2

        [1 - #include <abstractions/lxc/container-base>]
        2 - #include <abstractions/lxc/start-container> 
        3 - #include <abstractions/openssl> 
        4 - #include <abstractions/ssl_keys> 
        5 - owner /etc/ssl/openssl.cnf r, 
        (A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
        Adding #include <abstractions/lxc/container-base> to profile.
        Deleted 2 previous matching profile entries.

        = Changed Local Profiles =

        The following local profiles were changed. Would you like to save them?

        [1 - /usr/bin/curl]
        (S)ave Changes / Save Selec(t)ed Profile / [(V)iew Changes] / View Changes b/w (C)lean profiles / Abo(r)t
        Writing updated profile for /usr/bin/curl.
        ```
    
    1. curl profile was updated and we can use it.

1. Nginx Docker container uses AppArmor profile
    1. apparmor profile
        https://github.com/killer-sh/cks-course-environment/blob/master/course-content/system-hardening/kernel-hardening-tools/apparmor/profile-docker-nginx


    1. k8s docs apparmor
        https://kubernetes.io/docs/tutorials/clusters/apparmor/#example
    
    1. Create profile in /etc/apparmor.d/docker-nginx
    1. Run `apparmor_parser /etc/apparmor.d/docker-nginx`
    1. Run container with apparmor profile
        ```
        docker run --security-opt apparmor=docker-default nginx 
        /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
        /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
        10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
        10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
        /docker-entrypoint.sh: Configuration complete; ready for start up
        ```

1. AppArmor and Kunernetes
    1. Container runtime need to support AppArmor
    1. AppArmor need to be installed on every node
    1. AppArmor profiles need to be available on every node
    1. AppArmor profiles are specified per coontainer
        * done using annotations

# Seccomp

1. Secure computting mode
1. Security facility in the Linux Kernel
1. Restricts execution of syscalls
1. We can restrict syscalls that can be used. 
1. By default only allows: `exit`, `sigreturn`, `read`, `write`

1. Use seccomp in docker container
    1. Download seccom profile from: https://github.com/killer-sh/cks-course-environment/blob/master/course-content/system-hardening/kernel-hardening-tools/seccomp/profile-docker-nginx.json and save it as default.json

    1. Run docker container usin seccomp profile
        ```
        docker run --security-opt seccom=default.json nginx 
        docker: Error response from daemon: invalid --security-opt 2: "seccom=default.json".
        See 'docker run --help'.
        root@kubenode01:~# docker run --security-opt seccomp=default.json nginx 
        /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
        /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
        10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
        10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
        /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
        /docker-entrypoint.sh: Configuration complete; ready for start up
        ```

1. Use seccomp in K8s
    1. Make seccomp available in kubelet
        ```
        mkdir /var/lib/kubelet/seccomp
        root@kubenode01:~# mv default.json  /var/lib/kubelet/seccomp/
        ```