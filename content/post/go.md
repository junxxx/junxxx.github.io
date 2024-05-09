---
title: "A lecture of Go"
date: 2022-05-29T15:27:24+08:00
categories: ["CS", "Programming language"]
tags: ["Golang"]
author: "Paisen"
---
## 概述
串讲，是以会议形式，串讲人给同事讲一个topic。会上的其他同事，对串讲人进行相关知识的提问，以考查其对此topic的掌握程度。便于尽快上手，投入工作。

本文是一篇Go语言的串讲文档，所包含的知识点重在日常工作使用，不会深入研究底层的实现细节。

Go语言是一种`type`语言，可以这样说，everything in Golang is a `type`。
## Go语言中的Type
总的来说，Go中包含以下三种type
1. built-in type. 具体有numeric, string, boolean
2. reference type. 具体有 slice, map, interface, channel, function types
3. struct type. 

### built-in type
- numeric

    integer
    | type | size (bits) |
    | --- | --- |
    | int8 | 8 |
    | int16 | 16 |
    | int32 | 32 |
    | int64 | 64 |
    | int  | Platform dependent |

    float, float32和float64

    complex
    
- byte 和 rune 

    我们习惯称的 `byte` 是 uint8的别称， `rune` 是int32的别称 
- string  
    实际上string也是reference类型，底层是一个连续的固定字节序列。
    ```go
    var name = "Hello"
    var location = `Shanghai`
    ```
    
- boolean
    
    跟其他编程语言一样 `true` and `false`
    
- constants
    
    ```go
    const PI = 3.141592
    ```
- array

    ```go
    var num [3]int
    ```
    Go里的array跟C、C++、Java里的array为引用类型不同，其为value类型。这个要注意⚠️

### reference type
- slice  `[]T`
    
    含有同类型可变长度的序列 。slice的底层实现是数组，含有cap,len属性。
    
    ```go
    weeks := []string{"Mon","Tue","Wed","Thr","Fri","Sta", "Sun"}
   
- map `map[K]V`
    
    就是我们常用的key⇒value 关联无序数组，`map[K]V` 。但是与 `PHP` 的关联数组不一样，在Go中，一个map里的所有key的类型一致，所有vlaue的类型也一致。是reference类型。
    
    ```go
    age := make(map[string]int)
    ```
- channel

    `channel`是`goroutine`之前进行通信的桥梁，分为unbuffed和buffered两种。具有send,receive,close操作。
    ```go
    done := make(chan struct{}{})
    ```
- interface
- function type

### struct type 
由其他类型的字段组合成的结构体
    
```go
type Employee struct {
    Id int
    Name string
    Address string
    Position string
    Salary int
    ManagerId int
}
```

结构体比较，如果两个结构体里的所有字段都可以比较，那么这两个结构体则可以比较。

结构体可以嵌套，并且可以使用匿名字段。

## package

A *package* is a collection of source files in the same directory that are compiled together

## module

A repository contains one or more modules. A *module* is a collection of related Go packages that are released together. A Go repository typically contains only one module, located at the root of the repository

## function

function是重复利用代码的优秀实践。

```go
func FunctionName(input Type) Type { return Type}
```

defer, panic and recover

```go
package main

import "fmt"

func main() {
    f()
    fmt.Println("Returned normally from f.")
}

func f() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered in f", r)
        }
    }()
    fmt.Println("Calling g.")
    g(0)
    fmt.Println("Returned normally from g.")
}

func g(i int) {
    if i > 3 {
        fmt.Println("Panicking!")
        panic(fmt.Sprintf("%v", i))
    }
    defer fmt.Println("Defer in g", i)
    fmt.Println("Printing in g", i)
    g(i + 1)
}

/*
Calling g.
Printing in g 0
Printing in g 1
Printing in g 2
Printing in g 3
Panicking!
Defer in g 3
Defer in g 2
Defer in g 1
Defer in g 0
Recovered in f 4
Returned normally from f.
*/
```

## method

method是一个具体的Object拥有的behavior。

```go
func (o *obj)Say(p Type) {}
```

## interface

interface是一系列行为的集合，一个具体类型实现了接口的所有行为，则具体类型属于这个接口类型

```go
type iname interface {
	func1()
	func2()
}
```

## OOP in Go

- 封装：小写字母开头的变量，函数，只有本package可见。如果将package里的字段，变量和函数向外暴露，则大写字母开头。

- 继承：not supported！

- 多态:  通过interface，可以很优雅地实现多态。

## goroutine
Goroutine是由Go runtime管理的轻量线程。

`go` 关键字开启一个goroutine

```go
go func(){
	// do your work
}()
```
Go有如下两种并发方式：
1. Go提倡的 communicating sequential processes. use `channel` to communicate
2. 传统的 shared memory multithreading. use `mutal exclusion`

## channel
You can use `channel` to communicate between goroutine.
```go
ch <- v // Send v to channel ch.
c := <-ch // Receive from ch and assign value to v.
close(ch) // close channel ch.
```
- *unbuffered*

    By default, sends and receives block until the other side is ready.
    ```go
    ch := make(chan int)
    ```

- *buffered*

    Sends to a buffered channel block only when the buffer is full. Receives block when the buffer is empty
    ```go
    ch := make(chan int, 10) // buffered channel 
    ```

## Questions

1. What’s the difference between `make` and `new`?

    `make` is a built-in function, which only worked on slice, map and channel, return a regular values(slice, map or channel).

    `new` only returns pointers to initialised memory.

1. What will happened when two or more goroutine receive values on a unbuffered channel?
    
    Just like one receiving goroutine, multiple goroutine receive values on the same channel will block.
    
1. Which type is concurrency safe?

    As I know, channel is concurrency safe. Others  primitive type like slice, map, are not.
1. What is concurrency safe and how to make a type concurrency safe?
    1. not to write the variable
    2. avoid accessing the variable from multiple goroutines. If needed, can use channel to update variable between multiple goroutine
    3. allow many goroutine to access the variable, but only one at a time. This approach is known as `mutual exclusion`

## Reference
1. [How to Write Go Code](https://go.dev/doc/code)
1. [A tour of Go](https://go.dev/tour/list)
1. [Go in Action](https://livebook.manning.com/book/go-in-action/chapter-5/67)
1. [Defer, Panic, and Recover](https://go.dev/blog/defer-panic-and-recover)