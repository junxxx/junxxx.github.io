---
title: Debian折腾记
layout: post
date: 2016-11-21
categories: month
---

## 切不可忘了乐极生悲

小猪一砖一瓦地搭了自己的小窝，兴高采烈地安置了桌椅，高高兴兴地装置着小窝里的一点一滴。随着时间的流逝，在小猪的精心打造下，小窝越来越个性化。小窝越来越变得得心应手。小猪心里那个高兴啊，相当地有成就感。

在寻常的某天，晴天里的一个霹雳，一道电光击中小窝。忽然，小窝除了剩一堆废旧的框架，其它软设全部荡然无存。真是说不出小猪是什么心情。

无独有偶，我遇近身上也发生了跟上文中小猪类似的事情。

一步一步地把debian打造成自己喜爱的工具。安装php＋nginx＋mysql环境。解决git不能pull、push、clone的网络问题。vim安装YouCompeleteMe插件。安装markdown编辑器－－Remarkable。

似乎一切都变得越来越顺手，但是突然某次重启之后，提示（`Ext4 couldn‘t mount as ext3 due to ……Can‘t acces to tty……`）。起先看到这个提示，我心里还挺淡定，想着Google一下应该能解决。但是找着找着，心里越来越慌了——这个Bug不好解决啊。网上的方式一一尝试，最终无果。为了不浪费时间，最后还是下定决心重装了系统。尽管重装，好在当初装系统的时候，把／home单独分区了。重装系统之后，显卡驱动又有问题。

查看显卡型号`lscpi -nn | grep VGA`

<code>01:05.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] RS880 [Radeon HD 4200] [1002:9710]</code>

百度找了很多方法，最后最方便的还是[debian wiki](https://wiki.debian.org/AtiHowTo)。

**先备份 `sudo cp /etc/apt/source.list /etc/apt/source.list.bak`**
修改源文件，用最喜欢的文本编辑器打开/etc/apt/source.list文件。`sudo gedit /etc/apt/source.list` 保存退出。
更新源列表`sudo apt-get update`
安装驱动`apt-get install firmware-linux-nonfree libgl1-mesa-dri xserver-xorg-video-ati`。reboot重启，驱动也好了。

通过这次对debian的折腾，对linux又有了深一层次的体会。用好linux，得有一颗耐操的心，动手能力要强，遇到问题要会自己解决。一次不行，就再来一次。使用debian时间长了之后，真是对它的简洁，个性扩展性越来越爱不释手。

使用linux时间长了之后，越来越喜欢它了。一个重大原因，在linux环境下，各种编程各种方便，打游戏各种不方便，这样，更容易静下心来coding and write。
