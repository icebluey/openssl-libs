#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

umask 022

LDFLAGS='-Wl,-z,relro -Wl,--as-needed -Wl,-z,now'
export LDFLAGS
_ORIG_LDFLAGS="$LDFLAGS"

CC=gcc
export CC
CXX=g++
export CXX

/sbin/ldconfig

set -e

if ! grep -q -i '^1:.*docker' /proc/1/cgroup; then
    echo
    echo ' Not in a container!'
    echo
    exit 1
fi

_strip_and_zipman() {
    if [[ "$(pwd)" = '/' ]]; then
        echo
        printf '\e[01;31m%s\e[m\n' "Current dir is '/'"
        printf '\e[01;31m%s\e[m\n' "quit"
        echo
        exit 1
    else
        rm -fr lib64
        chown -R root:root ./
    fi
    find usr/ -type f -iname '*.la' -delete
    if [[ -d usr/share/man ]]; then
        find -L usr/share/man/ -type l -exec rm -f '{}' \;
        sleep 2
        find usr/share/man/ -type f -iname '*.[1-9]' -exec gzip -f -9 '{}' \;
        sleep 2
        find -L usr/share/man/ -type l | while read file; do ln -svf "$(readlink -s "${file}").gz" "${file}.gz" ; done
        sleep 2
        find -L usr/share/man/ -type l -exec rm -f '{}' \;
    fi
    if [[ -d usr/lib/x86_64-linux-gnu ]]; then
        find usr/lib/x86_64-linux-gnu/ -iname 'lib*.so*' -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' /usr/bin/strip '{}'
        find usr/lib/x86_64-linux-gnu/ -iname '*.so' -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' /usr/bin/strip '{}'
    fi
    if [[ -d usr/lib64 ]]; then
        find usr/lib64/ -iname 'lib*.so*' -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' /usr/bin/strip '{}'
        find usr/lib64/ -iname '*.so' -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' /usr/bin/strip '{}'
    fi
    if [[ -d usr/sbin ]]; then
        find usr/sbin/ -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' /usr/bin/strip '{}'
    fi
    if [[ -d usr/bin ]]; then
        find usr/bin/ -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' /usr/bin/strip '{}'
    fi
    if [[ -d usr/lib/gnupg2 ]]; then
        find usr/lib/gnupg2/ -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' /usr/bin/strip '{}'
    fi
}

_install_zlib() {
    set -e
    _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    _zlib_ver="$(wget -qO- 'https://www.zlib.net/' | grep -i 'HREF="zlib-[0-9].*\.tar\.' | sed 's|"|\n|g' | grep '^zlib-' | grep -ivE 'alpha|beta|rc' | sed -e 's|zlib-||g' -e 's|\.tar.*||g' | sort -V | uniq | tail -n 1)"
    wget -q -c -t 9 -T 9 "https://zlib.net/zlib-${_zlib_ver}.tar.xz"
    sleep 1
    tar -xof "zlib-${_zlib_ver}.tar.xz"
    sleep 1
    rm -f zlib-*.tar*
    cd "zlib-${_zlib_ver}"
    ./configure --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu --includedir=/usr/include --sysconfdir=/etc --64
    sleep 1
    make all
    rm -fr /tmp/zlib
    sleep 1
    make DESTDIR=/tmp/zlib install
    sleep 1
    cd /tmp/zlib/
    _strip_and_zipman
    echo
    sleep 2
    tar -Jcvf /tmp/zlib-"${_zlib_ver}"-1.ub.x86_64.tar.xz *
    echo
    sleep 2
    cd /tmp
    rm -fr "${_tmp_dir}"
    rm -f /usr/lib/x86_64-linux-gnu/libz.*
    tar -xof /tmp/zlib-"${_zlib_ver}"-1.ub.x86_64.tar.xz -C /
    sleep 2
    /sbin/ldconfig >/dev/null 2>&1
    rm -fr /tmp/zlib
    rm -f /tmp/zlib-"${_zlib_ver}"-1.ub.x86_64.tar.xz
}
_install_zlib

# OpenSSL
_tmp_dir="$(mktemp -d)"
cd "${_tmp_dir}"
LDFLAGS=''
LDFLAGS="${_ORIG_LDFLAGS}"' -Wl,-rpath,\$$ORIGIN'
export LDFLAGS
_ssl_ver="$(wget -qO- 'https://www.openssl.org/source/' | grep '1.1.1' | sed 's/">/ /g' | sed 's/<\/a>/ /g' | awk '{print $3}' | grep '\.tar.gz' | sed -e 's|openssl-||g' -e 's|\.tar.*||g' | sort -V | tail -n 1)"
wget -q -c -t 9 -T 9 "https://www.openssl.org/source/openssl-${_ssl_ver}.tar.gz"
sleep 1
tar -xof "openssl-${_ssl_ver}.tar.gz"
sleep 1
rm -f openssl*.tar.gz
cd openssl-*
sed '/define X509_CERT_FILE .*OPENSSLDIR "/s|"/cert.pem"|"/certs/ca-certificates.crt"|g' -i include/internal/cryptlib.h
sed '/install_docs:/s| install_html_docs||g' -i Configurations/unix-Makefile.tmpl
sleep 1
./Configure \
--prefix=/usr \
--libdir=/usr/lib/x86_64-linux-gnu \
--openssldir=/etc/ssl \
zlib enable-tls1_3 threads shared \
enable-camellia enable-seed enable-rfc3779 \
enable-sctp enable-cms enable-md2 enable-rc5 \
no-mdc2 no-ec2m \
no-sm2 no-sm3 no-sm4 \
enable-ec_nistp_64_gcc_128 linux-x86_64 \
'-DDEVRANDOM="\"/dev/urandom\""'
sleep 1
sed 's@engines-1.1@engines@g' -i Makefile
make all
rm -fr /tmp/openssl
sleep 1
install -m 0755 -d /tmp/openssl
make DESTDIR=/tmp/openssl install_sw
cd /tmp/openssl
_openssl111_ver="$(cat usr/include/openssl/opensslv.h | grep -i '# define OPENSSL_VERSION_TEXT' | sed 's/ /\n/g' | grep -i '^1\.1\.1')"
strip usr/bin/openssl
strip usr/lib/x86_64-linux-gnu/libssl.so.1.1
strip usr/lib/x86_64-linux-gnu/libcrypto.so.1.1
strip usr/lib/x86_64-linux-gnu/engines/*.so
install -m 0755 -d /tmp/"openssl-libs-${_openssl111_ver}-ub"
sleep 2
cp -af usr/lib/x86_64-linux-gnu/lib*.so* /tmp/"openssl-libs-${_openssl111_ver}-ub"/
cp -af /usr/lib/x86_64-linux-gnu/libz.so* /tmp/"openssl-libs-${_openssl111_ver}-ub"/
cd /tmp
echo
sleep 2
tar -Jcvf "openssl-libs-${_openssl111_ver}-ub".tar.xz "openssl-libs-${_openssl111_ver}-ub"
echo
sleep 2
cd /tmp
rm -fr "${_tmp_dir}"
rm -fr /tmp/openssl
rm -fr /tmp/"openssl-libs-${_openssl111_ver}-ub"
echo
echo ' done'
echo
exit

