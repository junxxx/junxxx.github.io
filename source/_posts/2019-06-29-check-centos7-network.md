---
layout: post
title: "记一次ss排错经历"
date: 2019-06-29
categories: note
---
背景 ：Linode上的VPS，服务商进行一次更新之后重启了服务器。重新启动ss-server之后，之前正常的ss连接不上了。

解决步骤：
凭借以往的经验，第一反应是ss端口被GFW禁了(以前经常被这样对待)。想都没想就直接将ss的端口换了一个。重新开启ss-server之后，客户端还是连接不上ss服务。进一步定位问题原因，发现服务器IP能够ping通，ssh服务连不上。这个又更加重了我对IP被ban的理解。这里面有很多思维误区，并没有去求证，这种习惯思维很不符合工程师思维，一点也不严谨，全是凭感觉在那解决问题。要不得，要不得。
在服务器上netstat查看ssh，ss-server的端口都是处于listen状态。借助[端口扫描工具](http://coolaf.com/tool/port)，进一步确认端口开放情况。发现所有的端口都没开放。到这一步，想到了是不是防火墙开启的原因。

```
firewall-cmd --state    #查看防火墙状态
systemctl stop firewalld.service   #停止防火墙
```
Guess what? It works!

总结：

针对上面的问题，进行复盘。ss client连接不上ss server，在排除账号设置错误的前题下，首先确认IP是否被GFW墙掉。如果IP能ping通，再查看ss server服务进程是否正常。如果ss-server服务正常，但是其端口没有开放，那大概率是防火墙拦掉了。关闭防火墙是一时偷懒的解决办法。

