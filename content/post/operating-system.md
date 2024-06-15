---
title: "Operating System"
date: 2024-05-09T10:46:18+08:00
categories: ["Tech", "CS"]
tags: ["OS"]
author: "Paisen"
---
## Introduction
As a human being living in the 21st century, it's possible you might not know what a OS is, but if you say you didn't use any OS, that's absolutely impossible!  If there's only one course need to learn in computer science branch, I will recommend **Operating System**. 

This article is a summary of the important concepts in a modern multi-users, time-sharing, interactive OS, like for a instance, Unix.

Modern OS is getting more complex due to the development of hardware. More and more features are add to OS kernel. But the foundamental concepts are similar.

Most of the OS are written in C, so in order to read OS source code well, you need to learn [C programming language]({{< ref "/c-programming-language.md" >}}) first.

Keep in mind, from a programmer's perspective, an OS is an implementation of hardwares(CPU, devices). Most of the features, such as **paging**, **user mode**, **kernel mode** etc, are provided by CPU.

To be honest, the concepts in OS are easy to forget if you didn't have a deep understand of it. In order to learn OS well, you need to combine practice with theory. I mean, it's better for you to write a couple of codes to build a small application than just reading a book.

OS provided a excellent abstraction to engineering, the philosophy behind the design of an OS is worth your time.
```
   application
     /shell\
    //kernel\\
  ///hardwares\\\
```
The goals of a multi-user, time-sharing OS are multiplexing, isolation and interaction.

Overall, the basic and the most important part in a OS are:
- [**Process**]({{< ref "/process-implementation.md" >}})
- [**Memory**]({{< ref "/memory-implementation.md" >}})
- **File System**
- **Input and Output**


## Abstraction
Different CPU(x86, arm, risc etc) has its own architure, an OS implement CPU's interface and provide a consistent API to users. 

### Process
We all know that programs written by a user or programmer using high-level programming languages, such as C, Java, and JavaScript, run on the CPU(Central Process Unit). 

On one hand, a process is an instance of a program running on a machine; on the other hand, process is an abstraction of the CPU.

A binary code of a program (generated by compiler) loaded to memory and CPU execute every instructions. It exits after execution. A process may be suspended by the OS(scheduler) to run another process. We can see that a process has a state and a life-cycle. 

### Memory
In order to achieve that process A shouldn't interrupt process B, every process has its own private address space. This is isolation! 

CPU fetch instructions from memory and save them in register. 
This procedure called load. CPU didn't load instructions from physical memory directly, other than virtual memory.
```
     VM
CPU ---> MMU ---> Physical Memory
    <---     <---
```

The feature of virtual memory is provided by the hardware, MMU(Memory Management Unit), a unit of CPU. We can say design a OS is just hardware-oriented programming, in other words, build a OS is implementting the interface provied by the hardware, usually the CPU.

### File
 
### IO

## Useful tools
```
strace
```

## Reference
1. [Operating Systems: Three Easy Pieces](https://www.amazon.co.jp/-/en/Remzi-H-Arpaci-Dusseau/dp/198508659X)
1. [Modern Operating Systems](https://www.amazon.co.jp/-/en/Andrew-Tanenbaum/dp/013359162X)