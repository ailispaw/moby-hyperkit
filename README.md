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
Welcome to Moby alpha
Kernel 4.4.15-moby on an x86_64 (/dev/ttyS0)

                        ##         .
                  ## ## ##        ==
               ## ## ## ## ##    ===
           /"""""""""""""""""___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
           \______ o           __/
             \    \         __/
              \____\_______/

moby login: root
Welcome to the Moby alpha, based on Alpine Linux.
moby:~# 
```

## Using Docker from Mac

```bash
moby:~# echo 'DOCKER_OPTS="-H 0.0.0.0:2375"' > /etc/conf.d/docker
moby:~# rc-service docker restart
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
Server Version: 1.12.0
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 0
 Dirperm1 Supported: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: null bridge host overlay
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Security Options: seccomp
Kernel Version: 4.4.15-moby
Operating System: Alpine Linux v3.4
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 994.3 MiB
Name: moby
ID: 7APB:NVZK:3S4G:K57J:QDLM:HUHV:C2GY:V5D6:XMMY:ZMK2:PBS5:OQDF
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Username: ailispaw
Registry: https://index.docker.io/v1/
Insecure Registries:
 127.0.0.0/8
```

## Setting up SSH and sudo

```bash
moby:~# apk update
moby:~# apk add openssh sudo
moby:~# /etc/init.d/sshd start
moby:~# echo "docker:docker" | chpasswd
moby:~# echo "%docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker
```

```bash
$ make ssh
moby-hyperkit: running on 192.168.64.4
docker@192.168.64.4's password:
Welcome to the Moby alpha, based on Alpine Linux.
moby:~$ 
```

## Setting up NFS mount

```bash
moby:~# vi /etc/init.d/nfsmount
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
moby:~# chmod +x /etc/init.d/nfsmount
moby:~# rc-update add nfsmount
moby:~# rc-service nfsmount start
moby:~# mount | grep 192.168.64.1
192.168.64.1:/Users/ailispaw on /Users/ailispaw type nfs (rw,noatime,vers=3,rsize=32768,wsize=32768,namlen=255,acregmin=1,acregmax=1,acdirmin=1,acdirmax=1,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.64.1,mountvers=3,mountport=777,mountproto=udp,local_lock=all,addr=192.168.64.1)
```