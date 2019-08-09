---
title: 修复sslocal不能使用的问题 
layout: post
date: 2016-11-21
categories: month
---
## 听说nginx比apache轻量，本着没事折腾的原则，在原来的基础上，新安装了nginx。Web server安装，调试好之后，数据库又出了问题。应该是相关的模块没有安装处理好。最严重的是，科学上网的sslocal也报错了。折腾了一会，没有细究。过了几天，总算是不折腾不死，花了几个小时，把科学上网弄好了。

之前client是用的`pip install shadowsocks`安装的ss。写好配置文件，config.json之后，只要sslocal -c config.json就可以运动，非常方便。装了nginx之后，装了相应的openssl模块，python写的shadowsocks就不行了。根据相应的报错，找到原因：openssl跟python socks有冲突。想到两个解决方法：
1，更新ss到最新版，｀pip install -U shadowsocks`。也报错。google找了半天也没有找到解决办法。所以换了另一种command line client－－－shadowsocks-libev。
2, 用shadowsocks－libev。其安装在debian下也是相当的简单方便。｀apt-get install shadowsocks-libev` 就可以。安装好之后，我照之前的方法`ss-local -c config.json`启动客户端，总是提示帮助信息，程序反倒不执行。好在它有自己的默认配置文件，diff file1 file2发现，默认的配置文件跟我自定义的文件就多了一个local_port。加上去之后，再启动就OK了。

git 之前clone，push,pull也是报错。“can't connect to 127.0.0.1:1080“。应该是git走了ss的代码。索性就设置个`git config --global http.proxy "socks5:127.0.0.1:1080"`。也OK了。

走代理之后,git clone https又出问题了。 Failed to receive SOCKS4 connect request ack.
换成clone 走ssh就没问题了。接下来把Vim 的YouCompleteMe装上。


