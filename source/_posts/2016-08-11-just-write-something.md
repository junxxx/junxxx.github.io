---
title: 昨天干了件蠢事
layout: post
date: 2016-08-11
categories: month
---
这两天将家里的ubuntu14.04升级到16.04的过程中，提示/boot空间不足。网上搜了一下，[Ubuntu下提示/boot空间不足解决办法](http://www.linuxidc.com/Linux/2015-05/117401.htm)。

卸载内核的过程中，不知怎么的，把所有的（包括正在使用的）内核都卸载了。尔后还鬼使神差地把机器重启了。重启之后的机器，只有两个memory test进不了系统。看到此情的我，两眼一黑，差点晕过去。

赶紧找解决方法，不想重装系统，修复/boot就可以。等有时间了再定定心心弄。

这两天都在弄这个问题，为了不重装系统，也是蛮拼的。折腾果然让人学习进步啊（插播一曲，这个五笔输入法怎么不可以打词组了？吓我一跳，原来是设置的问题).

上面找的方法,其实是可以解决问题的,但是自己一个没留意, linux /vmlinuz root=/dev/sda9　这里的root设置成/boot所在分区了.(我ubuntu的分区,/boot ,/ /home ,swap都是单独分区).死活都启不来,试了Ｎ次,boot之后都是进BuyBox v1.22.1(initramfs)_.后来又Google了很多,找来找去,解决方法跟上面的类似.后来把root=/dev/sda9设置成linux系统/所在分区就可以了.boot成功进入系统,但是,重启之后,显示grub_,没有菜单选项,还要手动加载kernel.内心还是很激动的!!!现在又进入解决另一种问题的困境了---修复grub启动项.

如果内核全部被卸载,解决思路:
通过USB启动进live系统,chroot安装内核,调整设置grub.


好没有重装系统.淡定.接下来,还是老老实实干活,少折腾这些没用的东西,太费时间和精力了.

8.14 update: I feel disappointed that spent about 3 days on fixing my broken system.The main subject consider Linux generic,GRUB boot loader.

不想折腾了,现在通过临时的vmlinuz 和initrd.lz内核文件启动系统,ubuntu是可以启动了,其它一切配置都正常,网络也可用,但是Win7还是启动不了.通过chroot安装新的内核之后,reboot电脑,驱动有问题,显卡驱动也有问题,鼠标不能用.暂时就用这种方式启动电脑.

8.25 update:

最后还是入手了ssd重装了debian。系统装完之后，显卡驱动问题又折腾了近一周，今天看到debian wiki上的AMD/ATI关于GPU的文档，按照文档的说明，成功安装了显卡驱动，现在显示全屏了，字也看起来舒服多了，还带有特效。看文档把系统弄好，真是好开心啊。

之前机械硬盘上的数据，直接开机挂载，也是很方便。现在把开发环境配置好，又可以定定心心写代码了。。。
