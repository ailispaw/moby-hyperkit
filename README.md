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
moby-hyperkit: running on 192.168.64.11
docker@192.168.64.11's password:
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
