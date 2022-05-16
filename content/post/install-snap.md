---
title: "Install Snap on Centos7"
date: 2022-05-15T21:48:33+08:00
draft: true
---
## 问题
在Centos7系统上安装`snap`，遇到的问题记录

```
[centos@ip-172-26-6-67 ~]$ sudo snap install core
error: system does not fully support snapd: cannot mount squashfs image using "squashfs": -----
       mount: wrong fs type, bad option, bad superblock on /dev/loop0,

       missing codepage or helper program, or other error

       In some cases useful info is found in syslog - try
       dmesg | tail or so.

       -----
```
Google一圈之后，解决方案如下：
```
[centos@ip-172-26-6-67 ~]$ sudo semodule -i /usr/share/selinux/packages/snappy.pp.bz2 
[centos@ip-172-26-6-67 ~]$ sudo snap install core
2022-05-15T13:49:30Z INFO Waiting for automatic snapd restart...
core 16-2.54.4 from Canonical✓ installed
[centos@ip-172-26-6-67 ~]$ sudo snap refresh core
snap "core" has no updates available
[centos@ip-172-26-6-67 ~]$ 
```

## 原因分析
这个坑有点深，不打算填了。

## Reference
1. [Installing snap on CentOS](https://snapcraft.io/docs/installing-snap-on-centos)
2. [安装snap遇到错误：error: system does not fully support snapd的解决办法](https://www.wahahahaohe.com/640.html)
