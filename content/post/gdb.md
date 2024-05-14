---
title: "Gdb"
date: 2018-07-12T15:24:58+08:00
categories: ["Tech", "Tools"]
tags: ["GDB"]
author: "Paisen"
---
This article keep tracks of the most used commands of GDB

Write a classic C program with your favoriate editor and save it as `main.c`.
```c
#include <stdio.h>

int main(int argc, char *argv[]) {
    printf("Hello world\n");
}
```
Compile it with `gcc`, which is a popular c/c++ compiler on linux.
```shell
gcc -o main -g main.c 
```
Debug with `gdb`
```shell
gdb main      // gdb programname -p [pid]
```
```
(gdb) b main  // set breakpoint
(gdb) layout src // gui
(gdb) p  // print p/x hex
(gdb) i b // list all breakpoints, you can list other info
```
```
┌─test.c───────────────────────────────────────────────────┐
│   3           int main(int argc, char *argv[]) {         │
│B+>4               printf("Hello world\n");               │
│   5           }                                          │
└──────────────────────────────────────────────────────────┘
process 31551 In: main             L4    PC: 0x555555555144
(gdb) r
Starting program: /home/junxxx/Workspace/the_c_language/test


Breakpoint 1, main (argc=1, argv=0x7fffffffe338)
    at test.c:4
(gdb)
```

| Abbreviation| Command| Explanation|
| --------| -- | ------- |
| b  | break| break [PROBE_MODIFIER] [LOCATION] [thread THREADNUM] [if CONDITION]|
| c  | continue    | conntinue [N] |
| s  | step | step [N] |
| n  | next | next [N] |
| p  | print|  print [[OPTION]... --] [/FMT] [EXP] |
| i  | info, inf| use help i to check out info|



## Reference
1. [Debugging with GDB](https://sourceware.org/gdb/current/onlinedocs/gdb.html/)