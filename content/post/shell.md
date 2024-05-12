---
title: "Shell"
date: 2018-05-18T10:46:56+08:00
draft: false
categories: ["CS", "Unix"]
tags: ["Shell"]
author: "Paisen"
---

Learn a shell a day, master Unix one day!

## Pipe
Process read previous process's output as its input and generate output to next process's input.
Use symbol `|` to create a pipeline, which a powerful skill in Unix.
```
// count the numbers of text file in current directory.
ls -la | grep *.txt | wc -l
```
## Xargs
Many programs, takes its arguments from the command line (`char *argv[]`) but ignores standard input `fd 0`. If you want to pipe the output of a program to input of another program that ignores standard input, like `rm`, you need to use `xargs`.

xargs - build and execute command lines from standard input
```
ls | grep trash | rm            // this won't work, because rm ignores standard input
ls | grep trash | xargs rm 
```

## Top
top - display Linux processes

```
top - 22:05:26 up 2 days,  2:48,  2 users,  load average: 0.00, 0.00, 0.00       
//     uptime                               over the last 1,    5,    15 minutes 

Tasks: 355 total,   1 running, 354 sleeping,   0 stopped,   0 zombie             
// task states

%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st  
// CPU states

MiB Mem :  16004.5 total,  12332.1 free,   2134.6 used,   1537.8 buff/cache      
// physical memory usage: total, free, used and buff/cache
MiB Swap:   7660.0 total,   7660.0 free,      0.0 used.  13560.5 avail Mem       
// virtual memory usage: total, free, used and avail (physical memory)
```
As  a default, percentages for these individual categories are displayed.  Where two labels are shown below, those for more recent
kernel versions are shown first.
```
us, user    : time running un-niced user processes
sy, system  : time running kernel processes
ni, nice    : time running niced user processes
id, idle    : time spent in the kernel idle handler
wa, IO-wait : time waiting for I/O completion
hi : time spent servicing hardware interrupts
si : time spent servicing software interrupts
st : time stolen from this vm by the hypervisor
```
Use `man top` to check out more infomation.

## Strace
strace - trace system calls and signals

In the simplest case strace runs the specified command until it exits.  It intercepts and  records  the  system  calls  which  are called  by  a process and the signals which are received by a process.  The name of each system call, its arguments and its return value are printed on standard error or to the file specified with the -o option.

## Nohup
nohup - run a command immune to hangups, with output to a non-tty

## Ps
ps - report a snapshot of the current processes

## Grep
grep, egrep, fgrep, rgrep - print lines that match patterns

## Netstat
netstat - Print network connections, routing tables, interface statistics, masquerade connections, and multicast memberships

By default, netstat displays a list of open sockets.  If you don't specify any address families, then the active  sockets  of  all configured address families will be printed.

This program is mostly obsolete.  Replacement for netstat is ss.  Replacement for netstat -r is ip route.  Replacement for netstat -i is ip -s link.  Replacement for netstat -g is ip maddr.

[--tcp|-t] [--udp|-u] [--listening|-l] [--all|-a] [--numberic|n]
```
// count how many ESTABLISHED TCP v4 sockets
netstat -altu4 | grep tcp |grep -i established | wc -l
```

## Ss
ss - another utility to investigate sockets

## Proc
proc - process information pseudo-filesystem

## Awk
mawk - pattern scanning and text processing language

## Sed
sed - stream editor for filtering and transforming text

Some tasks can be solved by using combination of a few shell.

1. 

## Reference