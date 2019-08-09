---
title: vsftp添加虚拟用户
layout: post
date: 2016-11-22
categories: server
---
项目开发过程中会经常遇到这样的情景：指定用户只能对指定的文件目录有权限。这时候给ftp服务器添加虚拟用户就很方便了。

centos6.5 vsftpd服务器。
```
yum install vsftpd
yum install db4-utils db4-devel db4
```
cat /etc/vsftpd/vsftpd.conf | grep -v '#'

```
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_file=/var/log/xferlog
xferlog_std_format=YES
chroot_local_user=YES
listen=NO
listen_ipv6=YES

pam_service_name=vsftpd
userlist_enable=YES
userlist_deny=NO
tcp_wrappers=YES
guest_enable=YES
guest_username=vuser
user_config_dir=/etc/vsftpd/vsftpd_user_conf
allow_writeable_chroot=YES
```
```
vim /etc/vsftpd/vuser_passwd.txt
user
pass
db_load -T -t hash -f /etc/vsftpd/vuser_passwd.txt /etc/vsftpd/vuser_passwd.db
vim /etc/pam.d/vsftpd
auth required pam_userdb.so db=/etc/vsftpd/vuser_passwd
account required pam_userdb.so db=/etc/vsftpd/vuser_passwd

mkdir /etc/vsftpd/vsftpd_user_conf/
vim /etc/vsftpd/vsftpd_user_conf/user
local_root=/opt/case/upload/ftpfile/
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
```


参考资料
1. [centos安装vsftpd虚拟账号](https://www.itgeeker.net/centos6-5-64bit-how-to-install-vsftpd/)
1. [vsftpd530错误解决方法](https://www.thegeekdiary.com/error-530-permission-denied-when-user-logs-in-to-vsftpd-server-via-ftp/)
1. [vsftpd500错误解决方法](https://www.liquidweb.com/kb/error-500-oops-vsftpd-refusing-to-run-with-writable-root-inside-chroot-solved/)
