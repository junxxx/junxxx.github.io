---
title: "Build your own tools"
date: 2019-04-22 
categories: ["Tools"]
tags: [""]
author: "Paisen"
---
## 背景
从拥有自己的第一台电脑至今，由于工作或其他原因，我已经换过好几台电脑。每一次拿到新电脑的第一件事，就是安装各种软件以及配置开发环境。手动下载，安装，这些工作其实完全可以自动化。
本篇文章持续记录自己工作和生活中用到的软件，最终目标，可以在新电脑上（Mac OS)能够一键安装所需的软件。

## 软件
cli
```
brew on-my-zsh squirrel 
```
gui
```
iterm2 vscode docker postman shadowsocks typora
```

### [Homebrew](https://brew.sh/)
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
### [iTerm2](https://www.iterm2.com/downloads.html)
### 输入法
[Rime](https://rime.im/download/)，是一款越用越顺手的输入法。轻量可自定义，关键还没有广告。
安装好之后，再下载[五笔拼音配置文件](https://github.com/junxxx/rime_wubi_pinyin)至Rime的配置目录
Mac版位于 ~/Library/Rime/
### 编辑器
[Vim](https://github.com/vim/vim)
### 开发环境
[Docker](https://docs.docker.com/get-started/)

[K8s](https://kubernetes.io/docs/home/)

自动化脚本托管在全球最大的同性交友网站[github](https://raw.githubusercontent.com/junxxx/dev_tools/master/mac/install.sh)上。执行以下命令进行自动安装：
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/junxxx/dev_tools/master/mac/install.sh)"
```

Don't Repeat Yourself!

