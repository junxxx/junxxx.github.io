---
title: Linux命令总结
layout: post
date: 2017-03-23
categories: linux
---
## 压缩:zip,tar
做项目的时候，经常需要将线上的文件打包下载到本地。一般情况下通过命令`zip -r target.zip source/folder`直接将项目文件夹打包。

# zip的基础用法：

`zip options archive inpath inpath ...` 

其中archive是新建的或是已经存在的压缩文件。

options：
> * -b path 将压缩的文件放入指定的目录
> * -e encrypt 加密
> * -i include files 只压缩指定的文件

# tar的基础用法：

`tar [option...] [file]...`

options:

> * -c create 新建压缩文件
> * -C 解压到指定目录
> * -r append 在压缩文件后追加
> * -x extract 从压缩文件中解压
> * -t list 查看压缩文件内容
> * -f file=ARCHIVE 
> * -j bzip2
> * -z gzip
> * -v gzip

现在需要将ABC文件夹打包，并且忽略其中的ef文件夹。试了命令`zip -r target.zip ABC -x path/to/ef`,结果在压缩的时候，还是将ef文件夹压缩进去了。后面的文件夹路径不管是相对还是绝对路径都不管用。无奈之下，用tar命令`tar -zcvf target.tar.gz --exclude=ef ABC`搞定。

## 同步:rsync 

Linux下非常好用的一个传输(同步)文件的命令。在首次用rsync命令传输过文件之后，再次用这个命令传输文件的时候，只会同步改变过的文件。

# 基础用法：
> Local  `rsync [OPTION...] SRC... [DEST]`

> Access via remote shell：

> Pull `rsync [OPTION...] [USER@]HOST:SRC... [DEST]`

> PUSH `rsync [OPTION...] SRC... [USER@]HOST:DEST`

将nginx加入PATH。编辑用户目录下的.bash_profile文件，在PATH的下一行加入`PATH=PATH:/path/to/nginx/sbin/nginx`。然后`source .bash_profile`。

挂载硬盘。

`fdisk -l`查看当前计算机上的硬盘。
`mount /dev/sdb1  /path/`将硬盘sdb1挂载到/path目录。
`df -h`查看当前计算机硬盘的挂载情况。

## apt-get安装软件包提示依赖错误的解决方法
更新源｀sudo apt-get update｀
