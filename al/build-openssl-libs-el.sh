#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

umask 022

LDFLAGS='-Wl,-z,relro -Wl,--as-needed -Wl,-z,now'
export LDFLAGS
_ORIG_LDFLAGS="${LDFLAGS}"

CC=gcc
export CC
CXX=g++
export CXX
/sbin/ldconfig

_private_dir='usr/local/private'

set -e

_strip_files() {
    if [[ "$(pwd)" = '/' ]]; then
        echo
        printf '\e[01;31m%s\e[m\n' "Current dir is '/'"
        printf '\e[01;31m%s\e[m\n' "quit"
        echo
        exit 1
    else
        rm -fr lib64
        rm -fr lib
        chown -R root:root ./
    fi
    find usr/ -type f -iname '*.la' -delete
    if [[ -d usr/share/man ]]; then
        find -L usr/share/man/ -type l -exec rm -f '{}' \;
        sleep 1
        find usr/share/man/ -type f -iname '*.[1-9]' -exec gzip -f -9 '{}' \;
        sleep 1
        find -L usr/share/man/ -type l | while read file; do ln -sf "$(readlink -s "${file}").gz" "${file}.gz" ; done
        sleep 1
        find -L usr/share/man/ -type l -exec rm -f '{}' \;
    fi
    for libroot in usr/lib/x86_64-linux-gnu usr/lib64; do
        [[ -d "$libroot" ]] || continue
        find "$libroot" -type f \( -iname '*.so' -or -iname '*.so.*' \) | xargs --no-run-if-empty -I '{}' chmod 0755 '{}'
        find "$libroot" -type f -iname 'lib*.so*' -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
        find "$libroot" -type f -iname '*.so' -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
    done
    for binroot in usr/sbin usr/bin; do
        [[ -d "$binroot" ]] || continue
        find "$binroot" -type f -exec file '{}' \; | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs --no-run-if-empty -I '{}' strip '{}'
    done
    libroot=''
    binroot=''
}

_build_zlib() {
    /sbin/ldconfig
    set -e
    local _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    _zlib_ver="$(wget -qO- 'https://www.zlib.net/' | grep 'zlib-[1-9].*\.tar\.' | sed -e 's|"|\n|g' | grep '^zlib-[1-9]' | sed -e 's|\.tar.*||g' -e 's|zlib-||g' | sort -V | uniq | tail -n 1)"
    wget -c -t 9 -T 9 "https://www.zlib.net/zlib-${_zlib_ver}.tar.gz"
    tar -xof zlib-*.tar.*
    sleep 1
    rm -f zlib-*.tar*
    cd zlib-*
    ./configure --prefix=/usr --libdir=/usr/lib64 --includedir=/usr/include --64
    make -j$(nproc --all) all
    rm -fr /tmp/zlib
    make DESTDIR=/tmp/zlib install
    cd /tmp/zlib
    _strip_files
    install -m 0755 -d "${_private_dir}"
    cp -af usr/lib64/*.so* "${_private_dir}"/
    /bin/rm -f /usr/lib64/libz.so*
    /bin/rm -f /usr/lib64/libz.a
    sleep 2
    /bin/cp -afr * /
    sleep 2
    cd /tmp
    rm -fr "${_tmp_dir}"
    rm -fr /tmp/zlib
    /sbin/ldconfig
}

_build_brotli() {
    /sbin/ldconfig
    set -e
    local _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    git clone --recursive 'https://github.com/google/brotli.git' brotli
    cd brotli
    rm -fr .git
    if [[ -f bootstrap ]]; then
        ./bootstrap
        rm -fr autom4te.cache
        LDFLAGS=''; LDFLAGS="${_ORIG_LDFLAGS}"' -Wl,--disable-new-dtags -Wl,-rpath,\$$ORIGIN'; export LDFLAGS
        ./configure \
        --build=x86_64-linux-gnu --host=x86_64-linux-gnu \
        --enable-shared --disable-static \
        --prefix=/usr --libdir=/usr/lib64 --includedir=/usr/include --sysconfdir=/etc
        make -j$(nproc --all) all
        rm -fr /tmp/brotli
        make install DESTDIR=/tmp/brotli
    else
        LDFLAGS=''; LDFLAGS="${_ORIG_LDFLAGS}"' -Wl,--disable-new-dtags -Wl,-rpath,\$ORIGIN'; export LDFLAGS
        cmake \
        -S "." \
        -B "build" \
        -DCMAKE_BUILD_TYPE='Release' \
        -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
        -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        -DINCLUDE_INSTALL_DIR:PATH=/usr/include \
        -DLIB_INSTALL_DIR:PATH=/usr/lib64 \
        -DSYSCONF_INSTALL_DIR:PATH=/etc \
        -DSHARE_INSTALL_PREFIX:PATH=/usr/share \
        -DLIB_SUFFIX=64 \
        -DBUILD_SHARED_LIBS:BOOL=ON \
        -DCMAKE_INSTALL_SO_NO_EXE:INTERNAL=0
        cmake --build "build" --parallel $(nproc --all) --verbose
        rm -fr /tmp/brotli
        DESTDIR="/tmp/brotli" cmake --install "build"
    fi
    cd /tmp/brotli
    _strip_files
    install -m 0755 -d "${_private_dir}"
    cp -af usr/lib64/*.so* "${_private_dir}"/
    sleep 2
    /bin/cp -afr * /
    sleep 2
    cd /tmp
    rm -fr "${_tmp_dir}"
    rm -fr /tmp/brotli
    /sbin/ldconfig
}

_build_zstd() {
    /sbin/ldconfig
    set -e
    local _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    git clone --recursive "https://github.com/facebook/zstd.git"
    cd zstd
    rm -fr .git
    sed '/^PREFIX/s|= .*|= /usr|g' -i Makefile
    sed '/^LIBDIR/s|= .*|= /usr/lib64|g' -i Makefile
    sed '/^prefix/s|= .*|= /usr|g' -i Makefile
    sed '/^libdir/s|= .*|= /usr/lib64|g' -i Makefile
    sed '/^PREFIX/s|= .*|= /usr|g' -i lib/Makefile
    sed '/^LIBDIR/s|= .*|= /usr/lib64|g' -i lib/Makefile
    sed '/^prefix/s|= .*|= /usr|g' -i lib/Makefile
    sed '/^libdir/s|= .*|= /usr/lib64|g' -i lib/Makefile
    sed '/^PREFIX/s|= .*|= /usr|g' -i programs/Makefile
    #sed '/^LIBDIR/s|= .*|= /usr/lib64|g' -i programs/Makefile
    sed '/^prefix/s|= .*|= /usr|g' -i programs/Makefile
    #sed '/^libdir/s|= .*|= /usr/lib64|g' -i programs/Makefile
    LDFLAGS=''; LDFLAGS="${_ORIG_LDFLAGS}"' -Wl,-rpath,\$$OOORIGIN'; export LDFLAGS
    #make -j$(nproc --all) V=1 prefix=/usr libdir=/usr/lib64
    make -j$(nproc --all) V=1 prefix=/usr libdir=/usr/lib64 -C lib lib-mt
    LDFLAGS=''; LDFLAGS="${_ORIG_LDFLAGS}"; export LDFLAGS
    make -j$(nproc --all) V=1 prefix=/usr libdir=/usr/lib64 -C programs
    make -j$(nproc --all) V=1 prefix=/usr libdir=/usr/lib64 -C contrib/pzstd
    rm -fr /tmp/zstd
    make install DESTDIR=/tmp/zstd
    install -v -c -m 0755 contrib/pzstd/pzstd /tmp/zstd/usr/bin/
    cd /tmp/zstd
    ln -svf zstd.1 usr/share/man/man1/pzstd.1
    _strip_files
    find usr/lib64/ -type f -iname '*.so*' | xargs -I '{}' chrpath -r '$ORIGIN' '{}'
    install -m 0755 -d "${_private_dir}"
    cp -af usr/lib64/*.so* "${_private_dir}"/
    rm -f /usr/lib64/libzstd.*
    sleep 2
    /bin/cp -afr * /
    sleep 2
    cd /tmp
    rm -fr "${_tmp_dir}"
    rm -fr /tmp/zstd
    /sbin/ldconfig
}

_build_openssl() {
    set -e
    IFS='.' read -r _major _minor _patch <<< "${1}"
    #_patch=${_patch:-0}
    local _tmp_dir="$(mktemp -d)"
    cd "${_tmp_dir}"
    _openssl_ver="$(wget -qO- 'https://openssl-library.org/source/index.html' | grep "openssl-${_major}\.${_minor}\." | sed 's|"|\n|g' | sed 's|/|\n|g' | grep -i "^openssl-${_major}\.${_minor}\..*\.tar\.gz$" | cut -d- -f2 | sed 's|\.tar.*||g' | sort -V | uniq | tail -n 1)"
    wget -c -t 9 -T 9 https://github.com/openssl/openssl/releases/download/openssl-${_openssl_ver}/openssl-${_openssl_ver}.tar.gz
    tar -xof openssl-*.tar*
    sleep 1
    rm -f openssl-*.tar*
    cd openssl-*
    sed '/install_docs:/s| install_html_docs||g' -i Configurations/unix-Makefile.tmpl

    if [ "${_major}.${_minor}" = "3.0" ]; then
        LDFLAGS=''; LDFLAGS="${_ORIG_LDFLAGS}"' -Wl,--disable-new-dtags -Wl,-rpath,\$$ORIGIN'; export LDFLAGS
        HASHBANGPERL=/usr/bin/perl
        ./Configure \
        --prefix=/usr \
        --libdir=/usr/lib64 \
        --openssldir=/etc/pki/tls \
        enable-zlib enable-tls1_3 threads \
        enable-camellia enable-seed \
        enable-rfc3779 enable-sctp enable-cms \
        enable-ec enable-ecdh enable-ecdsa \
        enable-ec_nistp_64_gcc_128 \
        enable-poly1305 enable-ktls \
        enable-md2 enable-rc5 \
        no-mdc2 no-ec2m \
        no-sm2 no-sm3 no-sm4 \
        shared linux-x86_64 '-DDEVRANDOM="\"/dev/urandom\""'
    else
        local _current_dir="$(pwd)"
        _build_brotli
        _build_zstd
        cd "${_current_dir}"
        LDFLAGS=''; LDFLAGS="${_ORIG_LDFLAGS}"' -Wl,--disable-new-dtags -Wl,-rpath,\$$ORIGIN'; export LDFLAGS
        HASHBANGPERL=/usr/bin/perl
        ./Configure \
        --prefix=/usr \
        --libdir=/usr/lib64 \
        --openssldir=/etc/pki/tls \
        enable-zlib enable-zstd enable-brotli \
        enable-argon2 enable-tls1_3 threads \
        enable-camellia enable-seed \
        enable-rfc3779 enable-sctp enable-cms \
        enable-ec enable-ecdh enable-ecdsa \
        enable-ec_nistp_64_gcc_128 \
        enable-poly1305 enable-ktls enable-quic \
        enable-ml-kem enable-ml-dsa enable-slh-dsa \
        enable-md2 enable-rc5 \
        no-mdc2 no-ec2m \
        no-sm2 no-sm2-precomp no-sm3 no-sm4 \
        shared linux-x86_64 '-DDEVRANDOM="\"/dev/urandom\""'
    fi
    perl configdata.pm --dump
    make -j$(nproc --all) all
    rm -fr /tmp/openssl
    make DESTDIR=/tmp/openssl install_sw
    cd /tmp/openssl
    sed 's|http://|https://|g' -i usr/lib64/pkgconfig/*.pc
    _strip_files
    install -m 0755 -d "${_private_dir}"
    cp -af usr/lib64/*.so* "${_private_dir}"/
    rm -fr /usr/include/openssl
    rm -fr /usr/include/x86_64-linux-gnu/openssl
    sleep 2
    /bin/cp -afr * /
    sleep 2
    cd /tmp
    rm -fr "${_tmp_dir}"
    rm -fr /tmp/openssl
    /sbin/ldconfig
}

############################################################################

/bin/rm -fr /usr/local/private

_build_zlib
_build_openssl "${1}"

_glibc_ver=$(strings $(ldd /usr/local/private/libssl.so | grep 'libc.so.6' | awk '{print $3}') | grep -i '^GLIBC_[0-9]' | sort -V | tail -n 1 | tr 'A-Z' 'a-z' | sed 's|_||g')
_dist=$(cat /etc/os-release | grep -i 'PLATFORM_ID' | awk -F: '{print $2}' | sed 's|"||g')

cd /tmp
/bin/rm -fr /tmp/_output
/bin/rm -fr /tmp/openssl-libs
mkdir /tmp/_output
/bin/cp -afr /usr/local/private /tmp/openssl-libs
echo
sleep 1
tar -Jcvf _output/openssl-libs-${_openssl_ver}-${_glibc_ver}.${_dist}.x86_64.tar.xz openssl-libs
echo
sleep 1
/bin/rm -fr /usr/local/private
/bin/rm -fr /tmp/openssl-libs

echo
echo " build openssl libs ${_dist} done"
echo
exit

