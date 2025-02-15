ssl dir and pem file
```
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
