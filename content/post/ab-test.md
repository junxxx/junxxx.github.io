---
title: "A tool for test server"
date: 2018-11-19T21:49:05+08:00
categories: ["Tech", "Tools"]
tags: ["test"]
author: "Paisen"
---
让我们来对服务器做一下压力测试吧！  
本篇文章讲一下压力测试应该怎么做，压力测试过程中需要注意哪些指标，以及需要注意的事项。  
首先，我们要清楚我们进行压测的目的是什么。是为了找出服务的性能瓶颈，还是为了检验当前服务能否扛住xxx量的并发？
俗话说，“不打无准备之仗”，首先要根据压测目的出一个可行的书面方案。  
下面是一个方案模板

**对某某某服务进行性能压力测试**
**背景说明：** 因为啥啥啥有xxx人同时在线，为了保障服务的稳定性，需要对某某某服务进行性能测试，检验其能否扛住xxx的量。  
**测试内容：** 一般是http的api。   
**服务端**
```
CPU： n核
内存：xMb
硬盘：可作相应的说明
web server： nginx(apache) + php7.1
```
**客户端**
```
客户端的配置简单列一下
压测工具：ab 版本
```
**具体的压测过程**
```
ab -n 1000 -c 1000 http url
# -n: Number of requests to perform  
# -c: Number of multiple requests to make at a time
```
逐步加大客户端请求的并发量，观察服务器的负载，记录相应资源(CPU、内存、网络I/O)的指标，以便得出最终结论。

压测结束之后，出一份带详细数据说明的报告。

### 可能的坑点
1、客户端并发提不上去，测不出服务器实际并发上限，解决方案为多客户端同时请求。  
2、单机有最大打开的文件限制，可用ulimit -a查看当前用户的具体参数。open files默认为1024，为提高服务的并发量，需要修改其默认值。
```
$ ulimit -a 
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 1684
max locked memory       (kbytes, -l) 16384
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 1684
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```
**PS.** 压测工具除了**ab**，还可以选用**apache jmeter**
```
jmeter -n -t scriptfile.jmx -l report/output.res -e -o report/index
# scriptfile.jmx: 测试脚本  
# report/output.res: 生成报告数据文件（不能为已存在的文件）  
# report/index: 生成报告存放目录（不能为已存在的目录） 
```
