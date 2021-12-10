# Containers

1. By default containers can't see processes from other containers

    ```
    # docker run --name c1 -d ubuntu sh -c 'sleep 1d'
    docker exec c1 ps aux
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root         1  0.6  0.0   2612   604 ?        Ss   21:57   0:00 sh -c sleep 1d
    root         6  0.0  0.0   2512   580 ?        S    21:57   0:00 sleep 1d
    root         7  0.0  0.1   5900  3024 ?        Rs   21:57   0:00 ps aux

    # docker run --name c2 -d ubuntu sh -c 'sleep 999d'
    docker exec c1 ps aux
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root         1  0.6  0.0   2612   604 ?        Ss   21:57   0:00 sh -c sleep 1d
    root         6  0.0  0.0   2512   580 ?        S    21:57   0:00 sleep 1d
    root         7  0.0  0.1   5900  3024 ?        Rs   21:57   0:00 ps aux
    ```

1. On node containers runs like separate processes

    ```
    # ps aux | grep sleep
    root     20629  0.1  0.0   2612   604 ?        Ss   21:57   0:00 sh -c sleep 1d
    root     20669  0.0  0.0   2512   580 ?        S    21:57   0:00 sleep 1d
    root     20883  0.1  0.0   2612   608 ?        Ss   21:57   0:00 sh -c sleep 999d
    root     20938  0.0  0.0   2512   588 ?        S    21:57   0:00 sleep 999d
    root     21127  0.0  0.0  14864  1028 pts/0    S+   21:57   0:00 grep --color=auto sleep
    ```

1. Default behaviour can be changed using `--pid=container:<container_name>` option
  
    ```
    # docker run --name c2  --pid=container:c1 -d ubuntu sh -c 'sleep 999d'
    # docker exec c2 ps aux
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root         1  0.0  0.0   2612   604 ?        Ss   21:57   0:00 sh -c sleep 1d
    root         6  0.0  0.0   2512   580 ?        S    21:57   0:00 sleep 1d
    root        12  1.2  0.0   2612   612 ?        Ss   21:58   0:00 sh -c sleep 999d
    root        17  0.0  0.0   2512   524 ?        S    21:58   0:00 sleep 999d
    root        18  0.0  0.1   5900  2880 ?        Rs   21:58   0:00 ps aux
    ```


# What have containers done for you lately? 
    
    https://www.youtube.com/watch?v=MHv6cWjvQjM
