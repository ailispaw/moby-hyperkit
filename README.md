# Moby running on HyperKit

It uses only Moby images and HyperKit from Docker for Mac.

## Requirements

- [Docker for Mac](https://docs.docker.com/docker-for-mac/)

## Ripping Moby images from Docker for Mac

```bash
$ git clone https://github.com/ailispaw/moby-hyperkit
$ cd moby-hyperkit
$ make init
```

## Booting Up

```bash
$ [SHARED_FOLDER=<dir>] make up    # You may be asked for your sudo password
Booting up...
```

- On Terminal.app: This will open a new window, then you will see in the window as below.
- On iTerm.app: This will split the current window, then you will see in the bottom pane as below.

```bash
Welcome to Moby

                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/


/ # 
```

## Using Docker from Mac

```bash
/ # echo 'DOCKER_OPTS="-H 0.0.0.0:2375"' > /etc/conf.d/docker
/ # rc-service docker restart
```

```bash
$ make env
moby-hyperkit: running on 192.168.64.4
export DOCKER_HOST=tcp://192.168.64.4:2375;
unset DOCKER_CERT_PATH;
unset DOCKER_TLS_VERIFY;
$ eval $(make env)
moby-hyperkit: running on 192.168.64.4
$ docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 17.09.1-ce
Storage Driver: overlay2
 Backing Filesystem: extfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
 Log: awslogs fluentd gcplogs gelf journald json-file logentries splunk syslog
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: 06b9cb35161009dcb7123345749fef02f7cea8e0
runc version: 3f2f8b84a77f73d38244dd690525642a72156c64
init version: 949e6fa
Security Options:
 seccomp
  Profile: default
Kernel Version: 4.9.49-moby
Operating System: Alpine Linux v3.5
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 992.7MiB
Name: moby
ID: 4AVN:SV3L:AONU:RNO2:5KCS:HYD4:BRJO:HZI7:5XCA:TPUQ:KYMF:CZBI
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): true
 File Descriptors: 17
 Goroutines: 26
 System Time: 2017-12-11T17:33:11.727837306Z
 EventsListeners: 0
Registry: https://index.docker.io/v1/
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
```

## Setting up SSH and sudo

```bash
/ # apk update
/ # apk add openssh sudo
/ # /etc/init.d/sshd start
/ # echo "docker:docker" | chpasswd
/ # echo "%docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker
```

```bash
$ make ssh
moby-hyperkit: running on 192.168.64.4
docker@192.168.64.4's password:
Welcome to Moby
moby:~$ 
```

## Setting up NFS mount

```bash
/ # vi /etc/init.d/nfsmount
#!/sbin/openrc-run

depend()
{
  need net
}

start()
{
  ebegin "Starting NFS Mount"

  SHARED_FOLDER=$(cat /proc/cmdline | sed -n 's/^.*hyperkit.shared_folder="\([^"]\+\)".*$/\1/p')
  if [ -z "${SHARED_FOLDER}" ]; then
    exit 1
  fi

  apk update
  apk add nfs-utils

  GW_IP="$(ip route get 8.8.8.8 | awk 'NR==1 {print $3}')"
  MOUNT_POINT="${SHARED_FOLDER}"
  mkdir -p "${MOUNT_POINT}"
  mount "${GW_IP}:${MOUNT_POINT}" "${MOUNT_POINT}" -o rw,async,noatime,rsize=32768,wsize=32768,nolock,vers=3,actimeo=1

  eend $? "Failed to start NFS Mount"
}
/ # chmod +x /etc/init.d/nfsmount
/ # rc-update add nfsmount
/ # rc-service nfsmount start
/ # mount | grep 192.168.64.1
192.168.64.1:/Users/ailispaw on /Users/ailispaw type nfs (rw,noatime,vers=3,rsize=32768,wsize=32768,namlen=255,acregmin=1,acregmax=1,acdirmin=1,acdirmax=1,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.64.1,mountvers=3,mountproto=tcp,local_lock=all,addr=192.168.64.1)
```
