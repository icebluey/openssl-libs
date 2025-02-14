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
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2204 -itd ubuntu:22.04 bash
else
    docker run --rm --name ub2204 -itd ubuntu:22.04 bash
fi
sleep 2
docker exec ub2204 apt update -y
#docker exec ub2204 apt upgrade -fy
docker exec ub2204 apt install -y bash vim wget ca-certificates curl
docker exec ub2204 /bin/ln -svf bash /bin/sh
docker exec ub2204 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp ub ub2204:/home/
docker exec ub2204 /bin/bash /home/ub/2204/.preinstall_ub2204
docker exec ub2204 /bin/bash /home/ub/build-openssl-libs-ub.sh '3.0'
mkdir -p /tmp/_output_assets
docker cp ub2204:/tmp/_output /tmp/_output_assets/
sleep 2
/bin/systemctl stop docker.socket docker.service containerd.service
/bin/rm -fr /var/lib/docker/* /var/lib/containerd/* /mnt/docker-data/*

# OpenSSL 3.3
systemctl start docker
sleep 2
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2204 -itd ubuntu:22.04 bash
else
    docker run --rm --name ub2204 -itd ubuntu:22.04 bash
fi
sleep 2
docker exec ub2204 apt update -y
#docker exec ub2204 apt upgrade -fy
docker exec ub2204 apt install -y bash vim wget ca-certificates curl
docker exec ub2204 /bin/ln -svf bash /bin/sh
docker exec ub2204 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp ub ub2204:/home/
docker exec ub2204 /bin/bash /home/ub/2204/.preinstall_ub2204
docker exec ub2204 /bin/bash /home/ub/build-openssl-libs-ub.sh '3.3'
mkdir -p /tmp/_output_assets
docker cp ub2204:/tmp/_output /tmp/_output_assets/
sleep 2
/bin/systemctl stop docker.socket docker.service containerd.service
/bin/rm -fr /var/lib/docker/* /var/lib/containerd/* /mnt/docker-data/*

# OpenSSL 3.4
systemctl start docker
sleep 2
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2204 -itd ubuntu:22.04 bash
else
    docker run --rm --name ub2204 -itd ubuntu:22.04 bash
fi
sleep 2
docker exec ub2204 apt update -y
#docker exec ub2204 apt upgrade -fy
docker exec ub2204 apt install -y bash vim wget ca-certificates curl
docker exec ub2204 /bin/ln -svf bash /bin/sh
docker exec ub2204 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp ub ub2204:/home/
docker exec ub2204 /bin/bash /home/ub/2204/.preinstall_ub2204
docker exec ub2204 /bin/bash /home/ub/build-openssl-libs-ub.sh '3.4'
mkdir -p /tmp/_output_assets
docker cp ub2204:/tmp/_output /tmp/_output_assets/
sleep 2
/bin/systemctl stop docker.socket docker.service containerd.service
/bin/rm -fr /var/lib/docker/* /var/lib/containerd/* /mnt/docker-data/*

exit

