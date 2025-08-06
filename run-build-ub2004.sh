#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
systemctl start docker
sleep 2
echo
cat /proc/cpuinfo
echo

# OpenSSL 3.0
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2004 -itd ubuntu:20.04 bash
else
    docker run --rm --name ub2004 -itd ubuntu:20.04 bash
fi
sleep 2
docker exec ub2004 apt update -y
#docker exec ub2004 apt upgrade -fy
docker exec ub2004 apt install -y bash vim wget ca-certificates curl
docker exec ub2004 /bin/ln -svf bash /bin/sh
docker exec ub2004 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp ub ub2004:/home/
docker exec ub2004 /bin/bash /home/ub/2004/.preinstall_ub2004
docker exec ub2004 /bin/bash /home/ub/build-openssl-libs-ub.sh '3.0'
mkdir -p /tmp/_output_assets
docker cp ub2004:/tmp/_output /tmp/_output_assets/
sleep 2
/bin/systemctl stop docker.socket docker.service containerd.service
/bin/rm -fr /var/lib/docker/* /var/lib/containerd/* /mnt/docker-data/*

# OpenSSL 3.5
systemctl start docker
sleep 2
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2004 -itd ubuntu:20.04 bash
else
    docker run --rm --name ub2004 -itd ubuntu:20.04 bash
fi
sleep 2
docker exec ub2004 apt update -y
#docker exec ub2004 apt upgrade -fy
docker exec ub2004 apt install -y bash vim wget ca-certificates curl
docker exec ub2004 /bin/ln -svf bash /bin/sh
docker exec ub2004 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp ub ub2004:/home/
docker exec ub2004 /bin/bash /home/ub/2004/.preinstall_ub2004
docker exec ub2004 /bin/bash /home/ub/build-openssl-libs-ub.sh '3.5'
mkdir -p /tmp/_output_assets
docker cp ub2004:/tmp/_output /tmp/_output_assets/
sleep 2
/bin/systemctl stop docker.socket docker.service containerd.service
/bin/rm -fr /var/lib/docker/* /var/lib/containerd/* /mnt/docker-data/*

exit

# OpenSSL 3.3
systemctl start docker
sleep 2
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2004 -itd ubuntu:20.04 bash
else
    docker run --rm --name ub2004 -itd ubuntu:20.04 bash
fi
sleep 2
docker exec ub2004 apt update -y
#docker exec ub2004 apt upgrade -fy
docker exec ub2004 apt install -y bash vim wget ca-certificates curl
docker exec ub2004 /bin/ln -svf bash /bin/sh
docker exec ub2004 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp ub ub2004:/home/
docker exec ub2004 /bin/bash /home/ub/2004/.preinstall_ub2004
docker exec ub2004 /bin/bash /home/ub/build-openssl-libs-ub.sh '3.3'
mkdir -p /tmp/_output_assets
docker cp ub2004:/tmp/_output /tmp/_output_assets/
sleep 2
/bin/systemctl stop docker.socket docker.service containerd.service
/bin/rm -fr /var/lib/docker/* /var/lib/containerd/* /mnt/docker-data/*
