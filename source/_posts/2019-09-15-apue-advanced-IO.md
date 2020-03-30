---
title: apue-advanced-IO
date: 2019-09-15 18:50:54
tags: apue
---

apue序列之-高级I/O

1. 非阻塞I/O
1. 记录锁
1. I/O多路复用
1. 异步I/O

早期的UNIX因为不支持文件的部分锁，所以不能用于跑数据库应用。

flock structure

协同锁

强制锁

### I/O模型
非阻塞IO,O_NONBLOCK flag
在打开文件描述符时，加入O_NONBLOCK flag。对于已经打开的文件描述符，用fcntl打开O_NONBLOCK flag

异步IO
不同系统的异步IO模型不一样。通过signal实现。

IO多路复用(select,poll)
IO多路复用是同步IO模型
将我们需要关注的文件描述符构建在一个列表中，然后调用一个直到有一个文件描述符准备好就有返回值的方法。poll,pselect,select可以支持IO多路复用

Memory-Mapped I/O
将硬盘上的文件，映射到内存的buffer中。所以，当我们从这个buffer中获取数据时，buffer相对应的硬盘数据被获取。相对应地，我们向这个buffer写数据时，这对应的bytes自动写入硬盘文件中。这个特性所用到的方法为`mmap`
