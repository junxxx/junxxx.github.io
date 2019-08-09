---
title: C 语言
layout: post
date: 2017-05-10
categories: C programing
---
## [程序设计教程](https://docs.huihoo.com/c/linux-c-programming/index.html)
1. 这门语言提供了哪些Primitive(基本类型)，比如基本类型，比如基本运算符、表达式和语句。

1. 这门语言提供了哪些组合规则，比如基本类型如何组成复合类型，比如简单的表达式和语句如何组成复杂的表达式和语句。

1. 这门语言提供了哪些抽象机制，包括数据抽象和过程抽象（Procedure Abstraction）。

区分并理解编译时，运行时
C语言的全局变量在定义时，如果不初始化，则其值为0。但是局部变量在初始化时如果不赋初值，则其值是不确定的。

函数的返回值，相当于定义一个和返回值类型相同的临时变量并用return后面的表达式对其进行初始化。

增量式编程,一块一块地添加，逐步检查增加的代码是不是有问题。

尽可能利用以前写的代码，避免写重复的代码。

递归和循环是造价的，用循环能做的事用递归都能做，反之亦然。

函数式编程，命令式编程，数据驱动编程

写代码最重要的是选择正确的数据结构来组织信息，设计控制流程和算法尚在其次，只要数据结构选择得正确，其它代码自然而然就变得容易理解和维护了

编译器总是从前到后找最长的合法的Token。

抽象

数组类型做右值使用时，自动转换成指向数组首元素的指针。

实际上编译器的工作分为两个阶段，先是预处理（Preprocess）阶段，然后才是编译阶段，用gcc的-E选项可以看到预处理之后、编译之前的程序
define定义是在预处理阶段处理的，而枚举是在编译阶段处理的

写代码时应尽可能避免硬编码

字符串字面值还有一点和数组名类似，做右值使用时自动转换成指向首元素的指针

use [indent](https://linux.die.net/man/1/indent) to format source code

如果某个函数的局部变量发生访问越界，有可能并不立即产生段错误，而是在函数返回时产生段错误。
## gdb
调试的基本思想仍然是“分析现象->假设错误原因->产生新的现象去验证假设”这样一个循环
gcc 编译时加上-g,生成的可执行文件才能用gdb进行源码级调试

```
use list line number to display source file 
next n step s backtrace bt
info i
frame f to select  frame number 
print 
finish
set var variable=value
display variable ondisplay
break b line or func_name
disable breakpoints number
delete breakpoints 
break ... if ...
continue c
run r
x/7b
watch
```



## scanf(),gets()
另一方面也让读者认识到，学C语言不可能不去了解底层计算机体系结构和操作系统的原理，不了解底层原理连一个scanf函数都没办法用好，更没有办法保证写出正确的程序
scanf()和gets()都可用于接收输入的字符串，但是scanf()不能接收空格，Tab和回车。gets()可以接收空格,接收到回车认为字符结束。两个函数都会在字符接收结束之后补全'\0'。

当在不同的环境中运行同一段代码，得到的结果不一样时，就要考虑是不是有未定义错误。
