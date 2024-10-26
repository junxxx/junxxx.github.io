---
title: "Vim"
date: 2018-06-21T10:47:01+08:00
draft: false
categories: ["Tools", "Editor"]
tags: ["Vim"]
author: "Paisen"
---

## 前言
本文记录“玩”[Vim](https://www.vim.org/)的经验，学习Vim是一件起步很困难的事，但是当你稍微熟悉它的操作模式之后，会对它爱不释手。

学习，或者换句话说，玩Vim，最重要的是实际上手去用，去玩，去实操。心态放平衡，不要想着一口气学完所有的技巧并掌握它，事实上，作为一款编辑器，只要它能满足你的实际需求就行，你平常用不到的那些高级特性，可以在你日后慢慢使用的过程中逐渐去尝试。

## 安装
### Mac
`brew install vim`
简单安装命令行版本。

`brew install macvim`
GUI版本

待玩得进阶之后，可以用[源代码](https://github.com/vim/vim)定制安装。

## 开始使用
最好最简捷的上手教程，在命令行执行`vimtutor`之后，即可以用Vim做一些基本的文本编程工作了。

### 编辑多个文件
一次打开多个文件，`vim 1.txt 2.txt 3.txt` 或是在打开一个文件 `vim 1.txt`，再编程另外的文件`:e 2.txt`，`:e 3.txt`。

打开多个文件之后，我们需要在不同的文件之间切换操作，我们可以用命令`:ls`查看buffer中有多少文件。
```
~
~
:ls
  1 %a   "1.txt"                        line 1
  2      "2.txt"                        line 0
  3      "3.txt"                        line 0
Press ENTER or type command to continue
```
上面的显示，我们一共打开了3个文件，我们可以用命令`:b+n（下一个）[p]（前一个）`，或是直接用buffer number或文件名切换。比如，我们现在正在编辑的文件是1.txt，我想切到3.txt，可以用以下的命令：
```
:b 3
```
```
:b 3.txt
```

- :e filename → Edit a new file.
- :bnext or :bn → Switch to the next buffer.
- :bprev or :bp → Switch to the previous buffer.
- :b buffer number → Switch to a specific buffer by number.
- :ls or :buffers → List all open files (buffers).
- <C-^> (Ctrl + ^) → Toggle between the current file and the last file.


### 纯文本编辑
在多个行首加入特定字符

Visual mode

`V` line visual

`C-v` block visual


### 编写简单脚本

#### Python

### 个性化设置
`:version` 可以查看vim的一些vimrc file路径。
```
system vimrc file: "$VIM/vimrc"
user vimrc file: "$HOME/.vimrc"
2nd user vimrc file: "~/.vim/vimrc"
3rd user vimrc file: "~/.config/vim/vimrc"
```
`vim ~/.vimrc` 新建一个本用户的vimrc配置文件，然后`:r $VIMRUNTIME/vimrc_example.vim` 读取vimrc的示例文件内容。

以下是逐步加入的个性化设置:
```
"Turn on number
set nu

" Number of spaces to use to TAB
set softtabstop=4
" Number of spaces to use for each indent
set shiftwidth=4
```

一位程序员想要的理想文本编辑器，当然除了编辑文本之外，还要写代码相当顺手。
