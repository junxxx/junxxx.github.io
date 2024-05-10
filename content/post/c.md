---
title: "C Programming Language"
date: 2024-05-09T10:47:40+08:00
draft: false
categories: ["CS", "Programming Language"]
tags: ["C"]
author: "Paisen"
---
**The C Programming Language** is the best textbook for a beginner who wants to learn C. This article mostly talks about pointers and memory in C.

C's syntax is simple but handling pointers in C is too easy to get stuck.

## Primitive data types and sizes
char, int, float, double

signed, unsigned, short, long

constant

```C
printf("%u\n", sizeof(int));
printf("%u\n", sizeof(char));
printf("%u\n", sizeof(float));
```

## Array
Array is a continuous fixed-length address. Different data types have different sizes. `sizeof` returns the size(how many bytes it holds to represent a data) of a data.
```C
// declare an array
type var[length];
type var[] = {};
```

### Buffer overflow
If you attemptes to write data beyond the bounds of array or buffer.
```C
int breads[5];
breads[5] = 10; // overflow
```

### String
A string in C is actually an array of `char` type, teminated with the `'\0'` charactor, which equals to 0. So you will see this code often.
```C
char name[10] = {'P', 'a', 'i', 'S', 'e', 'n', '\0'};
//or
char *name = "PaiSen";
printf("name: %s\n", name);
char *p = name;
while(*p) {
    printf("%c\n", *p);
    p++;
}
```
What's the difference between `char name[10]` and `char *name`?

### Array of strings
```C
char *argv[] = {"ls", "/home/user", "-la"};
```

## Pointer
A pointer is a variable contains another variable's address in memory.

Technically speaking, memory is a large lenght array of continuous bytes. A 32-bit machine can maximumly have 2^32=4294967296 bytes, which is 4GB.

A pointer is a variable, so it has a type. `&` is used to get the address of a variable. `*` is used to get the content in a pointer. `void *` is a special pointer, which can point to any type.

`NULL` pointer in C is defined as `(void *) 0`.

```C
int number = 20;
int *i;         // i is a pointer, which point to a integer variable
i = &number;    // assign the address of number to pointer i
char c = 'H';
char *cp = &c;
void *any;
any = i;
printf("any = %d\n", *(int *)any);
any = cp;
printf("any = %c\n", *(char *)any);
```
### Memory leak
Allocated memory dynamically but fails (or forget) to release that memory when it's no longer needed.

### Array and pointer
A name of an array is actually the address of that data.

```C
char name[MAX_LEN] = {'H','E','L', 'L', 'O', 0};
printf("%p, %p, %c, %c\n", name, &name[0], *(name+1), name[1]);
```
`name+1` is the address of the second element in array `name`, so if a pointer `p` points to the location of `name`, `p+1` then points to the next address in memory.

### Dynamic array
When you can't decide the lenght of an array at compile time, you can allocate dynamic memory at runtime.
```C
int n;
scanf("%d", &n);
printf("n=%d\n", n);
int *dynNumber = (int *)malloc(n*sizeof(int));

for(int i = 0;i < n;i++) {
    dynNumber[i] = 121;
}

for(int i = 0;i < n;i++) {
    printf("%d\n", *(dynNumber+i));
}
// don't forget to free dynNumber if you don't need it later.
free(dynNumber);
```


## Structs 
```C
// Mutual exclusion lock.
struct spinlock {
  uint locked;       // Is the lock held?

  // For debugging:
  char *name;        // Name of lock.
  struct cpu *cpu;   // The cpu holding the lock.
};
```

## Library and system call

## Reference