ssl dir and pem file
```

if [ -e /etc/ssl/certs/ca-certificates.crt ] && [ ! -e /etc/ssl/cert.pem ]; then ln -sv certs/ca-certificates.crt /etc/ssl/cert.pem; fi
if [ -e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem ] && [ ! -e /etc/ssl/cert.pem ]; then ([ -e /etc/ssl ] || install -m 0755 -d /etc/ssl) && ln -sv /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/cert.pem; fi

strings libcrypto.so | grep -i cert

el:
/etc/pki/tls/certs
/etc/pki/tls/cert.pem

# ls -la /etc/pki/tls
total 16
drwxr-xr-x 1 root root    88 Oct  9 13:39 .
drwxr-xr-x 1 root root    17 Sep 23 14:48 ..
lrwxrwxrwx 1 root root    49 Aug 21 19:20 cert.pem -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
drwxr-xr-x 1 root root     6 Oct  9 13:38 certs
-rw-r--r-- 1 root root   412 Oct  9 13:33 ct_log_list.cnf
drwxr-xr-x 1 root root     6 Oct  9 13:39 misc
-rw-r--r-- 1 root root 11227 Oct  9 13:33 openssl.cnf
drwxr-xr-x 1 root root     6 Oct  9 13:38 private

# ls -la /etc/pki/tls/certs
total 0
drwxr-xr-x 1 root root  6 Oct  9 13:38 .
drwxr-xr-x 1 root root 88 Oct  9 13:39 ..
lrwxrwxrwx 1 root root 49 Aug 21 19:20 ca-bundle.crt -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
lrwxrwxrwx 1 root root 55 Aug 21 19:20 ca-bundle.trust.crt -> /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt

# ls -la /etc/pki/tls/cert.pem
lrwxrwxrwx 1 root root 49 Aug 21 19:20 /etc/pki/tls/cert.pem -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem



ubuntu:
/etc/ssl/certs
/etc/ssl/cert.pem

# ls -la /etc/ssl 
total 36
drwxr-xr-x 4 root root    53 Feb 15 09:37 .
drwxr-xr-x 1 root root  4096 Feb 15 09:37 ..
drwxr-xr-x 2 root root 12288 Feb 15 09:37 certs
-rw-r--r-- 1 root root 12419 Aug 20 17:27 openssl.cnf
drwx------ 2 root root     6 Aug 20 17:27 private

# ls -la /etc/ssl/certs
total 464
drwxr-xr-x 2 root root  12288 Feb 15 09:37  .
drwxr-xr-x 4 root root     53 Feb 15 09:37  ..
...
lrwxrwxrwx 1 root root     23 Feb 15 09:37  002c0b4f.0 -> GlobalSign_Root_R46.pem
lrwxrwxrwx 1 root root     49 Feb 15 09:37  bf53fb88.0 -> Microsoft_RSA_Root_Certificate_Authority_2017.pem
lrwxrwxrwx 1 root root     22 Feb 15 09:37  c01eb047.0 -> UCA_Global_G2_Root.pem
lrwxrwxrwx 1 root root     34 Feb 15 09:37  c28a8a30.0 -> D-TRUST_Root_Class_3_CA_2_2009.pem
-rw-r--r-- 1 root root 219342 Feb 15 09:37  ca-certificates.crt
lrwxrwxrwx 1 root root     37 Feb 15 09:37  ca6e4ad9.0 -> ePKI_Root_Certification_Authority.pem
lrwxrwxrwx 1 root root     44 Feb 15 09:37  cbf06781.0 -> Go_Daddy_Root_Certificate_Authority_-_G2.pem
...

# ls -la /etc/ssl/cert.pem
ls: cannot access '/etc/ssl/cert.pem': No such file or directory

[[ -e /etc/ssl/cert.pem ]] || ln -svf certs/ca-certificates.crt /etc/ssl/cert.pem

```

```
# ubuntu 2004 / 2204
root@a5a72b8fdd57:~# stat /etc/ssl
  File: /etc/ssl
  Size: 53        	Blocks: 0          IO Block: 4096   directory
Device: 2dh/45d	Inode: 9586139     Links: 4
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2025-05-25 15:36:52.630739703 +0000
Modify: 2025-05-25 15:36:09.278382907 +0000
Change: 2025-05-25 15:36:09.278382907 +0000
 Birth: -
root@a5a72b8fdd57:~# ll /etc/ssl
total 32
drwxr-xr-x 4 root root    53 May 25 15:36 ./
drwxr-xr-x 1 root root  4096 May 25 15:36 ../
drwxr-xr-x 2 root root 12288 May 25 15:36 certs/
-rw-r--r-- 1 root root 10909 Feb  5 13:26 openssl.cnf
drwx------ 2 root root     6 Feb  5 13:26 private/
root@a5a72b8fdd57:~# 

# create /etc/ssl/cert.pem
if [ -e /etc/ssl/certs/ca-certificates.crt ] && [ ! -e /etc/ssl/cert.pem ]; then ln -sv certs/ca-certificates.crt /etc/ssl/cert.pem; fi


# al9
bash-5.1# stat /etc/ssl
  File: /etc/ssl
  Size: 77        	Blocks: 0          IO Block: 4096   directory
Device: 2fh/47d	Inode: 52487315    Links: 2
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2025-05-25 15:55:19.266836033 +0000
Modify: 2025-05-20 21:02:02.000000000 +0000
Change: 2025-05-25 15:55:19.245835861 +0000
 Birth: 2025-05-25 15:55:13.854791675 +0000
bash-5.1# ll /etc/ssl
total 0
drwxr-xr-x 2 root root 77 May 20 21:02 .
drwxr-xr-x 1 root root 69 May 25 15:57 ..
lrwxrwxrwx 1 root root 49 Aug 21  2024 cert.pem -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
lrwxrwxrwx 1 root root 18 Aug 21  2024 certs -> /etc/pki/tls/certs
lrwxrwxrwx 1 root root 28 Aug 21  2024 ct_log_list.cnf -> /etc/pki/tls/ct_log_list.cnf
lrwxrwxrwx 1 root root 24 Aug 21  2024 openssl.cnf -> /etc/pki/tls/openssl.cnf
bash-5.1# 


# al8
[root@ee4c17fc9578 ~]# stat /etc/ssl
  File: /etc/ssl
  Size: 6         	Blocks: 0          IO Block: 4096   directory
Device: 31h/49d	Inode: 33696736    Links: 1
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2025-05-25 16:19:26.117726203 +0000
Modify: 2025-05-25 16:22:56.228461041 +0000
Change: 2025-05-25 16:22:56.228461041 +0000
 Birth: 2025-05-25 16:18:26.790237804 +0000
[root@ee4c17fc9578 ~]# ll /etc/ssl
total 0
drwxr-xr-x 1 root root  6 May 25 16:22 .
drwxr-xr-x 1 root root 80 May 25 16:13 ..
lrwxrwxrwx 1 root root 16 Aug 21  2024 certs -> ../pki/tls/certs
[root@ee4c17fc9578 ~]# 

# create /etc/ssl/cert.pem
#if [ -d /etc/ssl ] && [ ! -e /etc/ssl/cert.pem ] && [ -e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem ]; then ln -sv /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/cert.pem; fi
#if [ -d /etc/ssl ] && [ ! -e /etc/ssl/cert.pem ] && [ -e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem ]; then ln -sv ../pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/cert.pem; fi
if [ -e /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem ] && [ ! -e /etc/ssl/cert.pem ]; then ([ -e /etc/ssl ] || install -m 0755 -d /etc/ssl) && ln -sv /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/cert.pem; fi

```
