# Syscall and processes

1. System calls can be performed from application processes: Firefox, curl

    ```
    https://man7.org/linux/man-pages/man2/syscalls.2.html
    ```

1. `strace`:
    1. Intercepts and logs calls made by a process
    1. Log and displays signals received by a process
    1. Diagnostic, Learning, Debugging

        ```
        root@kubemaster:/var/log/pods# strace ls /
        execve("/bin/ls", ["ls", "/"], 0x7ffe7c2663d8 /* 30 vars */) = 0
        brk(NULL)                               = 0x55ff9f10e000
        access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
        access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
        openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
        fstat(3, {st_mode=S_IFREG|0644, st_size=22788, ...}) = 0
        mmap(NULL, 22788, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f199c75a000
        close(3)                                = 0
        access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
        openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libselinux.so.1", O_RDONLY|O_CLOEXEC) = 3
        read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\20b\0\0\0\0\0\0"..., 832) = 832
        fstat(3, {st_mode=S_IFREG|0644, st_size=154832, ...}) = 0
        mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f199c758000
        mmap(NULL, 2259152, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f199c30f000
        mprotect(0x7f199c334000, 2093056, PROT_NONE) = 0
        mmap(0x7f199c533000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x24000) = 0x7f199c533000
        mmap(0x7f199c535000, 6352, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f199c535000
        close(3)                                = 0
        ...
        ```

        ```
        root@kubemaster:/var/log/pods# strace -cw ls /
        bin   dev  home        initrd.img.old  lib64       media  opt   root  sbin  srv  tmp  vagrant  vmlinuz
        boot  etc  initrd.img  lib             lost+found  mnt    proc  run   snap  sys  usr  var      vmlinuz.old
        % time     seconds  usecs/call     calls    errors syscall
        ------ ----------- ----------- --------- --------- ----------------
        39.65    0.009013         300        30           mmap
        11.45    0.002603         217        12           mprotect
        9.17    0.002084          80        26           close
        8.39    0.001907          79        24           openat
        7.66    0.001741          70        25           fstat
        6.70    0.001522         190         8         8 access
        5.31    0.001208         134         9           read
        4.39    0.000998         998         1           execve
        1.78    0.000404         135         3           brk
        1.23    0.000280         140         2           write
        0.94    0.000214         107         2         2 statfs
        0.49    0.000112          56         2           rt_sigaction
        0.44    0.000099          99         1           prlimit64
        0.40    0.000090          90         1           munmap
        0.33    0.000075          38         2           getdents
        0.33    0.000074          74         1           arch_prctl
        0.26    0.000059          30         2           ioctl
        0.25    0.000056          56         1           set_tid_address
        0.24    0.000054          54         1           rt_sigprocmask
        0.24    0.000054          54         1           set_robust_list
        0.23    0.000053          53         1           futex
        0.14    0.000031          31         1           stat
        ------ ----------- ----------- --------- --------- ----------------
        100.00    0.022731                   156        10 total
        ```

1. `/proc` directory
    1. Information and connections to process and kernel
    1. Study it to learn how processes work
    1. Configuration and administrative tasks
    1. Contains files that don't exist, yet you can access these
    1. Example:
        1. Check process pid
            ```
            ps aux | grep etcd
            root      7252  9.0 14.9 1098316 305348 ?      Ssl  17:43  18:37 kube-apiserver --advertise-address=192.168.56.2 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --insecure-port=0 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/12 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
            root      7339  2.0  2.9 10612728 61108 ?      Ssl  17:43   4:12 etcd --advertise-client-urls=https://192.168.56.2:2379 --cert-file=/etc/kubernetes/pki/etcd/server.crt --client-cert-auth=true --data-dir=/var/lib/etcd --initial-advertise-peer-urls=https://192.168.56.2:2380 --initial-cluster=kubemaster=https://192.168.56.2:2380 --key-file=/etc/kubernetes/pki/etc/server.key --listen-client-urls=https://127.0.0.1:2379,https://192.168.56.2:2379 --listen-metrics-urls=http://127.0.0.1:2381 --listen-peer-urls=https://192.168.56.2:2380 --name=kubemaster --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt --peer-client-cert-auth=true --peer-key-file=/etc/kubernetes/pki/etcd/peer.key --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt --snapshot-count=10000 --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
            root     18096  0.0  0.0  14864  1036 pts/0    S+   21:10   0:00 grep --color=auto etcd
            ```
        1. List syscalls
            ```
            root@kubemaster:/var/log/pods# strace -p 7252 -f -cw 
            strace: Process 7252 attached with 9 threads
            Cstrace: Process 7252 detached
            strace: Process 7405 detached
            strace: Process 7406 detached
            strace: Process 7407 detached
            strace: Process 7415 detached
            strace: Process 7509 detached
            strace: Process 7510 detached
            strace: Process 7511 detached
            strace: Process 7646 detached
            % time     seconds  usecs/call     calls    errors syscall
            ------ ----------- ----------- --------- --------- ----------------
            79.06  306.279135        8791     34839      8262 futex
            17.85   69.150832        1983     34870        58 epoll_pwait
            2.67   10.335338         483     21411         1 nanosleep
            0.23    0.877966         230      3819           write
            0.12    0.466697          89      5217      1692 read
            0.01    0.046774         121       386        60 rt_sigreturn
            0.01    0.042617          84       510           getrandom
            0.01    0.042027         109       386           getpid
            0.01    0.036992          96       386           tgkill
            0.01    0.035905          61       584           setsockopt
            0.01    0.034859         207       168           sched_yield
            0.01    0.020772         127       164        82 accept4
            0.00    0.009747          51       192        24 epoll_ctl
            0.00    0.006517          78        84           getsockname
            0.00    0.005373          56        96           close
            0.00    0.001130          94        12           openat
            0.00    0.000673          56        12           fstat
            0.00    0.000265         133         2         2 connect
            0.00    0.000157          79         2           socket
            0.00    0.000077          39         2           getsockopt
            0.00    0.000040          20         2           getpeername
            ------ ----------- ----------- --------- --------- ----------------
            100.00  387.393893                103144     10181 total
            ```

        1. Check proc open files
            ```
            root@kubemaster:/proc/7339/fd# ls -tlrah
            total 0
            dr-xr-xr-x 9 root root  0 Feb 11 21:00 ..
            lrwx------ 1 root root 64 Feb 11 21:00 90 -> 'socket:[40246]'
            lr-x------ 1 root root 64 Feb 11 21:00 9 -> /var/lib/etcd/member/wal
            lrwx------ 1 root root 64 Feb 11 21:00 89 -> 'socket:[40244]'
            lrwx------ 1 root root 64 Feb 11 21:00 88 -> 'socket:[40230]'
            lrwx------ 1 root root 64 Feb 11 21:00 87 -> 'socket:[40228]'
            lrwx------ 1 root root 64 Feb 11 21:00 86 -> 'socket:[39772]'
            lrwx------ 1 root root 64 Feb 11 21:00 85 -> 'socket:[40226]'
            lrwx------ 1 root root 64 Feb 11 21:00 84 -> 'socket:[39768]'
            lrwx------ 1 root root 64 Feb 11 21:00 83 -> 'socket:[40224]'
            lrwx------ 1 root root 64 Feb 11 21:00 82 -> 'socket:[40221]'
            lrwx------ 1 root root 64 Feb 11 21:00 81 -> 'socket:[40219]'
            lrwx------ 1 root root 64 Feb 11 21:00 80 -> 'socket:[39764]'
            l-wx------ 1 root root 64 Feb 11 21:00 8 -> /var/lib/etcd/member/wal/0000000000000000-0000000000000000.wal
            lrwx------ 1 root root 64 Feb 11 21:00 79 -> 'socket:[39762]'
            lrwx------ 1 root root 64 Feb 11 21:00 78 -> 'socket:[39760]'
            lrwx------ 1 root root 64 Feb 11 21:00 77 -> 'socket:[39758]'
            lrwx------ 1 root root 64 Feb 11 21:00 76 -> 'socket:[39756]'
            lrwx------ 1 root root 64 Feb 11 21:00 75 -> 'socket:[39754]'
            lrwx------ 1 root root 64 Feb 11 21:00 74 -> 'socket:[39752]'
            lrwx------ 1 root root 64 Feb 11 21:00 73 -> 'socket:[39750]'
            lrwx------ 1 root root 64 Feb 11 21:00 72 -> 'socket:[39748]'
            lrwx------ 1 root root 64 Feb 11 21:00 71 -> 'socket:[40206]'
            lrwx------ 1 root root 64 Feb 11 21:00 70 -> 'socket:[40203]'
            lrwx------ 1 root root 64 Feb 11 21:00 7 -> /var/lib/etcd/member/snap/db
            lrwx------ 1 root root 64 Feb 11 21:00 69 -> 'socket:[39744]'
            lrwx------ 1 root root 64 Feb 11 21:00 68 -> 'socket:[40199]'
            lrwx------ 1 root root 64 Feb 11 21:00 67 -> 'socket:[40197]'
            lrwx------ 1 root root 64 Feb 11 21:00 66 -> 'socket:[39740]'
            lrwx------ 1 root root 64 Feb 11 21:00 65 -> 'socket:[39736]'
            lrwx------ 1 root root 64 Feb 11 21:00 64 -> 'socket:[39733]'
            lrwx------ 1 root root 64 Feb 11 21:00 63 -> 'socket:[39730]'
            lrwx------ 1 root root 64 Feb 11 21:00 62 -> 'socket:[39727]'
            lrwx------ 1 root root 64 Feb 11 21:00 61 -> 'socket:[39724]'
            lrwx------ 1 root root 64 Feb 11 21:00 60 -> 'socket:[39721]'
            lrwx------ 1 root root 64 Feb 11 21:00 6 -> 'socket:[39398]'
            lrwx------ 1 root root 64 Feb 11 21:00 59 -> 'socket:[39718]'
            lrwx------ 1 root root 64 Feb 11 21:00 58 -> 'socket:[39717]'
            lrwx------ 1 root root 64 Feb 11 21:00 57 -> 'socket:[39713]'
            lrwx------ 1 root root 64 Feb 11 21:00 56 -> 'socket:[39710]'
            lrwx------ 1 root root 64 Feb 11 21:00 55 -> 'socket:[39707]'
            lrwx------ 1 root root 64 Feb 11 21:00 54 -> 'socket:[39704]'
            lrwx------ 1 root root 64 Feb 11 21:00 53 -> 'socket:[39701]'
            lrwx------ 1 root root 64 Feb 11 21:00 52 -> 'socket:[39698]'
            lrwx------ 1 root root 64 Feb 11 21:00 51 -> 'socket:[39695]'
            lrwx------ 1 root root 64 Feb 11 21:00 50 -> 'socket:[39692]'
            lrwx------ 1 root root 64 Feb 11 21:00 5 -> 'socket:[39397]'
            lrwx------ 1 root root 64 Feb 11 21:00 49 -> 'socket:[39689]'
            lrwx------ 1 root root 64 Feb 11 21:00 48 -> 'socket:[39686]'
            lrwx------ 1 root root 64 Feb 11 21:00 47 -> 'socket:[39683]'
            lrwx------ 1 root root 64 Feb 11 21:00 46 -> 'socket:[39680]'
            lrwx------ 1 root root 64 Feb 11 21:00 45 -> 'socket:[39677]'
            lrwx------ 1 root root 64 Feb 11 21:00 44 -> 'socket:[39674]'
            lrwx------ 1 root root 64 Feb 11 21:00 43 -> 'socket:[39671]'
            lrwx------ 1 root root 64 Feb 11 21:00 42 -> 'socket:[39668]'
            lrwx------ 1 root root 64 Feb 11 21:00 41 -> 'socket:[39665]'
            lrwx------ 1 root root 64 Feb 11 21:00 40 -> 'socket:[39662]'
            lrwx------ 1 root root 64 Feb 11 21:00 4 -> 'anon_inode:[eventpoll]'
            lrwx------ 1 root root 64 Feb 11 21:00 39 -> 'socket:[39659]'
            lrwx------ 1 root root 64 Feb 11 21:00 38 -> 'socket:[39656]'
            lrwx------ 1 root root 64 Feb 11 21:00 37 -> 'socket:[40194]'
            lrwx------ 1 root root 64 Feb 11 21:00 36 -> 'socket:[39652]'
            lrwx------ 1 root root 64 Feb 11 21:00 35 -> 'socket:[39649]'
            lrwx------ 1 root root 64 Feb 11 21:00 34 -> 'socket:[39646]'
            lrwx------ 1 root root 64 Feb 11 21:00 33 -> 'socket:[39643]'
            lrwx------ 1 root root 64 Feb 11 21:00 32 -> 'socket:[39639]'
            lrwx------ 1 root root 64 Feb 11 21:00 31 -> 'socket:[39636]'
            lrwx------ 1 root root 64 Feb 11 21:00 30 -> 'socket:[39633]'
            lrwx------ 1 root root 64 Feb 11 21:00 3 -> 'socket:[39393]'
            lrwx------ 1 root root 64 Feb 11 21:00 29 -> 'socket:[39630]'
            lrwx------ 1 root root 64 Feb 11 21:00 28 -> 'socket:[39626]'
            lrwx------ 1 root root 64 Feb 11 21:00 27 -> 'socket:[39623]'
            lrwx------ 1 root root 64 Feb 11 21:00 26 -> 'socket:[39620]'
            lrwx------ 1 root root 64 Feb 11 21:00 25 -> 'socket:[39617]'
            lrwx------ 1 root root 64 Feb 11 21:00 24 -> 'socket:[39614]'
            lrwx------ 1 root root 64 Feb 11 21:00 23 -> 'socket:[39611]'
            lrwx------ 1 root root 64 Feb 11 21:00 22 -> 'socket:[39609]'
            lrwx------ 1 root root 64 Feb 11 21:00 21 -> 'socket:[40187]'
            lrwx------ 1 root root 64 Feb 11 21:00 20 -> 'socket:[40184]'
            l-wx------ 1 root root 64 Feb 11 21:00 2 -> 'pipe:[38656]'
            lrwx------ 1 root root 64 Feb 11 21:00 19 -> 'socket:[40182]'
            lrwx------ 1 root root 64 Feb 11 21:00 18 -> 'socket:[39596]'
            lrwx------ 1 root root 64 Feb 11 21:00 17 -> 'socket:[39592]'
            lrwx------ 1 root root 64 Feb 11 21:00 16 -> 'socket:[39584]'
            lrwx------ 1 root root 64 Feb 11 21:00 15 -> 'socket:[40044]'
            lrwx------ 1 root root 64 Feb 11 21:00 14 -> 'socket:[40043]'
            lrwx------ 1 root root 64 Feb 11 21:00 13 -> 'socket:[40040]'
            lrwx------ 1 root root 64 Feb 11 21:00 12 -> 'socket:[40039]'
            l-wx------ 1 root root 64 Feb 11 21:00 11 -> /var/lib/etcd/member/wal/0.tmp
            lrwx------ 1 root root 64 Feb 11 21:00 10 -> 'socket:[39507]'
            l-wx------ 1 root root 64 Feb 11 21:00 1 -> 'pipe:[38655]'
            lrwx------ 1 root root 64 Feb 11 21:00 0 -> /dev/null
            dr-x------ 2 root root  0 Feb 11 21:00 .
            ```
        
        1. Search for content in etcd proc files
            ```
            cat 7 | strings | grep 12345 -A 20 -B 20
            coordination.k8s.io/v1beta1
            Lease
            kube-controller-manager
            kube-system"
            *$91f12d52-addd-4ce5-88f5-3cdd1f6ea6a92
            kube-controller-manager
            Update
            coordination.k8s.io/v1"
            FieldsV1:|
            z{"f:spec":{"f:acquireTime":{},"f:holderIdentity":{},"f:leaseDurationSeconds":{},"f:leaseTransitions":{},"f:renewTime":{}}}
            /kubemaster_deea82b6-5b08-4f93-81cf-adc53b0891e7
            %/registry/secrets/default/credit-card
            Secret
            credit-card
            default"
            *$7e5a3328-9c3a-499a-b407-423d49ecbb812
            kubectl-create
            Update
            FieldsV1:+
            ){"f:data":{".":{},"f:cc":{}},"f:type":{}}
            12345
            Opaque
            4/registry/leases/kube-system/kube-controller-manager
            coordination.k8s.io/v1beta1
            Lease
            kube-controller-manager
            kube-system"
            *$91f12d52-addd-4ce5-88f5-3cdd1f6ea6a92
            kube-controller-manager
            Update
            coordination.k8s.io/v1"
            FieldsV1:|
            z{"f:spec":{"f:acquireTime":{},"f:holderIdentity":{},"f:leaseDurationSeconds":{},"f:leaseTransitions":{},"f:renewTime":{}}}
            /kubemaster_deea82b6-5b08-4f93-81cf-adc53b0891e7
            +/registry/leases/kube-system/kube-scheduler
            coordination.k8s.io/v1beta1
            Lease
            kube-scheduler
            kube-system"
            *$cb64623d-e6ad-45ba-a948-3107481a8c8a2
            kube-scheduler
            ```
        
        1. Reads sectet from host filesystem
            ```
            kubectl run apache --image=httpd --env=SECRET=5555  
            ```

            ```
            kubectl exec apache -- env | grep SECRET
            SECRET=5555
            ```
        
        1. On Worker node check httpd process id
            ```
            root@kubenode01:~# docker ps | grep apache
            01a09577e624        httpd                   "httpd-foreground"       4 minutes ago       Up 4 minutes                            k8s_apache_apache_default_f074c5ee-0d1b-44d7-a33d-3b059514ed0d_0
            05fbdb774eaf        k8s.gcr.io/pause:3.2    "/pause"                 6 minutes ago       Up 6 minutes                            k8s_POD_apache_default_f074c5ee-0d1b-44d7-a33d-3b059514ed0d_0
            ```

            ```
            pstree -p
            ```
        1. Then need to find container shim 
            ```
            root@kubenode01:~# pstree -p | grep httpd
                    |                   |-containerd-shim(26539)-+-httpd(26564)-+-httpd(26593)-+-{httpd}(26597)
            ```
        
        1. Navigate to process id dir
            ```
            root@kubenode01:/proc/26564# ls -lh exe
            lrwxrwxrwx 1 root root 0 Feb 13 21:34 exe -> /usr/local/apache2/bin/httpd
            ```
        
        1. Check environment variable of the process
            ```
            root@kubenode01:/proc/26564# cat environ 
            KUBERNETES_PORT=tcp://10.96.0.1:443KUBERNETES_SERVICE_PORT=443HTTPD_VERSION=2.4.46HOSTNAME=apacheHOME=/rootHTTPD_PATCHES=KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1PATH=/usr/local/apache2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/binKUBERNETES_PORT_443_TCP_PORT=443KUBERNETES_PORT_443_TCP_PROTO=tcpHTTPD_SHA256=740eddf6e1c641992b22359cabc66e6325868c3c5e2e3f98faf349b61ecf41eaSECRET=5555HTTPD_PREFIX=/usr/local/apache2KUBERNETES_SERVICE_PORT_HTTPS=443KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443KUBERNETES_SERVICE_HOST=10.96.0.1PWD=/usr/local/apache2root@kubenode01:/proc/26564# 
            ```

# Falco

1. Cloud-Native runtime security 
1. ACCESS
    * Deep kernel tracing build on the Linux kernel
1. ASSERT
    * Describe security rules against a system 
    * Detect unwanted behaviour
1. ACTION
    * Automated respond to a security violations
1. Install Falco
    ```
    curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
    echo "deb https://dl.bintray.com/falcosecurity/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
    apt-get update -y
    apt-get -y install linux-headers-$(uname -r)
    apt-get install -y falco
    ```
1. Docs about falco
    https://v1-16.docs.kubernetes.io/docs/tasks/debug-application-cluster/falco

1. Check/Start Falco service
    ```
    root@kubenode01:/proc/26564# systemctl start falco
    root@kubenode01:/proc/26564# systemctl status falco
    ● falco.service - LSB: Falco syscall activity monitoring agent
    Loaded: loaded (/etc/init.d/falco; generated)
    Active: active (running) since Sat 2021-02-13 21:55:35 UTC; 1s ago
        Docs: man:systemd-sysv-generator(8)
    Process: 9521 ExecStart=/etc/init.d/falco start (code=exited, status=0/SUCCESS)
        Tasks: 10 (limit: 2361)
    CGroup: /system.slice/falco.service
            └─9542 /usr/bin/falco --daemon --pidfile=/var/run/falco.pid

    Feb 13 21:55:35 kubenode01 falco[9541]: Loading rules from file /etc/falco/falco_rules.yaml:
    Feb 13 21:55:35 kubenode01 falco[9521]: Sat Feb 13 21:55:35 2021: Loading rules from file /etc/falco/falco_rules.yaml:
    Feb 13 21:55:35 kubenode01 falco[9541]: Loading rules from file /etc/falco/falco_rules.local.yaml:
    Feb 13 21:55:35 kubenode01 falco[9521]: Sat Feb 13 21:55:35 2021: Loading rules from file /etc/falco/falco_rules.local.ya
    Feb 13 21:55:35 kubenode01 falco[9541]: Loading rules from file /etc/falco/k8s_audit_rules.yaml:
    Feb 13 21:55:35 kubenode01 falco[9521]: Sat Feb 13 21:55:35 2021: Loading rules from file /etc/falco/k8s_audit_rules.yaml
    Feb 13 21:55:35 kubenode01 systemd[1]: Started LSB: Falco syscall activity monitoring agent.
    Feb 13 21:55:35 kubenode01 falco[9542]: Starting internal webserver, listening on port 8765
    Feb 13 21:55:35 kubenode01 falco[9542]: 21:55:35.616057000: Notice Privileged container started (user=root user_loginuid=
    lines 1-18
    ```

1. Falco config files
    ```
    cd /etc/falco/
    root@kubenode01:/etc/falco# ls
    falco.yaml  falco_rules.local.yaml  falco_rules.yaml  k8s_audit_rules.yaml  rules.available  rules.d
    root@kubenode01:/etc/falco#
    ```

1. Check Falco logs
    ```
    root@kubenode01:/etc/falco# tail -f /var/log/syslog | grep falco
    Feb 13 21:55:35 ubuntu-bionic kernel: [17096.699119] falco: CPU buffer initialized, size=8388608
    Feb 13 21:55:35 ubuntu-bionic kernel: [17096.699120] falco: starting capture
    Feb 13 21:55:35 ubuntu-bionic falco: Starting internal webserver, listening on port 8765
    Feb 13 21:55:35 ubuntu-bionic falco: 21:55:35.616057000: Notice Privileged container started (user=root user_loginuid=0 command=container:0cb918921430 k8s_weave_weave-net-pxkdr_kube-system_324b6d66-2f00-4ee5-9439-72d40178840f_0 (id=0cb918921430) image=weaveworks/weave-kube:2.8.1)
    Feb 13 21:55:35 ubuntu-bionic falco: 21:55:35.623298535: Notice Privileged container started (user=root user_loginuid=0 command=container:69ab1c0440d9 k8s_weave-npc_weave-net-pxkdr_kube-system_324b6d66-2f00-4ee5-9439-72d40178840f_0 (id=69ab1c0440d9) image=weaveworks/weave-npc:2.8.1)
    Feb 13 21:56:41 ubuntu-bionic falco: 21:56:41.106381616: Error File below /etc opened for writing (user=root user_loginuid=1000 command=vim falco.yaml parent=bash pcmdline=bash file=/etc/falco/.falco.yaml.swp program=vim gparent=sudo ggparent=bash gggparent=sshd container_id=host image=<NA>)
    Feb 13 21:56:41 ubuntu-bionic falco: 21:56:41.106405680: Error File below /etc opened for writing (user=root user_loginuid=1000 command=vim falco.yaml parent=bash pcmdline=bash file=/etc/falco/.falco.yaml.swx program=vim gparent=sudo ggparent=bash gggparent=sshd container_id=host image=<NA>)
    Feb 13 21:56:41 ubuntu-bionic falco: 21:56:41.106481591: Error File below /etc opened for writing (user=root user_loginuid=1000 command=vim falco.yaml parent=bash pcmdline=bash file=/etc/falco/.falco.yaml.swp program=vim gparent=sudo ggparent=bash gggparent=sshd container_id=host image=<NA>)
    Feb 13 21:57:14 ubuntu-bionic falco: 21:57:14.316069060: Error File below / or /root opened for writing (user=root user_loginuid=1000 command=vim falco.yaml parent=bash file=/root/.viminfo program=vim container_id=host image=<NA>)
    ```

1. Use Falco to find malicious processes inside containers
    1. Check Falco logs on worker node
        ```
        root@kubenode01:/etc/falco# tail -f /var/log/syslog | grep falco
        Feb 13 21:55:35 ubuntu-bionic kernel: [17096.699119] falco: CPU buffer initialized, size=8388608
        ```
    1. On master node exec to the container
        ```
        kubectl exec apache -it sh
        kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
        # 
        ```
    1. Check Falco logs
        ```
        Feb 13 22:01:19 ubuntu-bionic falco: 22:01:19.385819588: Notice A shell was spawned in a container with an attached terminal (user=root user_loginuid=-1 k8s_apache_apache_default_f074c5ee-0d1b-44d7-a33d-3b059514ed0d_0 (id=01a09577e624) shell=sh parent=runc cmdline=sh terminal=34816 container_id=01a09577e624 image=httpd)
        ```
    1. Try to update /etc/passwd and check what will be listed in Falco logs
        ```
        Feb 13 22:03:04 ubuntu-bionic falco: 22:03:04.399197302: Error File below /etc opened for writing (user=root user_loginuid=-1 command=sh parent=<NA> pcmdline=<NA> file=/etc/passswd program=sh gparent=<NA> ggparent=<NA> gggparent=<NA> container_id=01a09577e624 image=httpd)
        ```
    1. Run com command in pod. 
        ```
        Feb 13 22:10:55 ubuntu-bionic falco: 22:10:55.188079566: Error Package management process launched in container (user=root user_loginuid=-1 command=apt-get update container_id=dc1404c63e1f container_name=k8s_apache_apache_default_379f1134-8735-46c6-ae6b-16ca6a499383_0 image=httpd:latest)
        Feb 13 22:10:58 ubuntu-bionic falco: 22:10:58.188242417: Error Package management process launched in container (user=root user_loginuid=-1 command=apt-get update container_id=dc1404c63e1f container_name=k8s_apache_apache_default_379f1134-8735-46c6-ae6b-16ca6a499383_0 image=httpd:latest)
        Feb 13 22:11:01 ubuntu-bionic falco: 22:11:01.171876919: Error Package management process launched in container (user=root user_loginuid=-1 command=apt-get update container_id=dc1404c63e1f container_name=k8s_apache_apache_default_379f1134-8735-46c6-ae6b-16ca6a499383_0 image=httpd:latest)
        Feb 13 22:11:04 ubuntu-bionic falco: 22:11:04.195697788: Error Package management process launched in container (user=root user_loginuid=-1 command=apt-get update container_id=dc1404c63e1f container_name=k8s_apache_apache_default_379f1134-8735-46c6-ae6b-16ca6a499383_0 image=httpd:latest)
        ```


1. Run `falco` manually without servive
    ```
    systemctl stop falco

    falco
    ```

1. Falco resources
    * https://falco.org/docs/rules/supported-fields
    * https://www.youtube.com/watch?v=8g-NUUmCeGI
