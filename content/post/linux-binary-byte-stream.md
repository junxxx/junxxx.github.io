---
title: "Linux 二进制探秘：从 strings 到 hexdump"
date: 2026-05-21T14:30:00+08:00
draft: false
categories: ["CS", "Linux"]
tags: ["Binary", "Linux Tools", "Hexdump"]
author: "Paisen"
---

第一次接触 Linux 二进制世界的人，通常都会有一种错觉：**txt 文件，不就是纯文本吗？**

直到有一天，我在做 OverTheWire Bandit 时，看到这样一道题：

> 题目要求在 `data.txt` 中找到一个人类可读的字符串。于是问题来了：既然是 “.txt”，为什么里面会有二进制？为什么需要用 `strings`？

今天我通过一系列实验，重新认识了 Linux 下的“文件”。

## 1. 文件，从来都不是“文本”

Linux 里有一个非常底层、但也非常重要的概念：**文件本质上只是连续的字节流（bytes stream）。**

操作系统并不关心这是文本、图片还是视频，它只看到一串 bytes。所谓的“文件类型”，只是人类或程序对这些 bytes 的解释方式。

让我们做一个实验：

```bash
# 创建一个混合了文本和二进制字节的文件
printf "Hello\x00\xff\x88\x99World" > data.txt
```

当我们尝试 `cat` 这个文件时：

```bash
cat data.txt
# 输出:Hello���World
```

终端会尝试显示这些字节，但 `\x00` (NULL) 和 `\xff` 等并不是可打印的 ASCII 字符，所以会出现乱码或不可见。

## 2. strings 的本质：沙里淘金

这时候，`strings` 工具的作用就体现出来了：

```bash
strings data.txt
# 输出：
# Hello
# World
```

`strings` 的逻辑很简单：**扫描文件，找出连续的可打印 ASCII 字符。** 它会自动忽略掉中间那些 `00 ff 88 99` 等非打印字节。这也是为什么在逆向工程或 ELF 文件分析中，`strings` 是第一步利器。

## 3. printf：向 stdout 写 bytes

以前我以为 `printf` 只是打印字符串，但更准确的理解是：**printf 是在向 stdout 写入特定的 bytes。**

例如：
- `printf "\x41"` 写入的是 `0x41`，在 ASCII 中对应 'A'。
- `printf "\x00\xff"` 写入的是对应的原始字节。

甚至我们可以输出带有颜色的字符：
```bash
printf "\033[31mred\033[0m"
```
这里的 `\033` (ESC) 并不是文本，而是控制终端显示行为的特殊指令字节。

## 4. hexdump：看见“真实”的世界

要真正看见文件的样子，我们需要 `hexdump` 或 `xxd`。

```bash
hexdump -C data.txt
```

输出如下：
```text
00000000  48 65 6c 6c 6f 00 ff 88  99 57 6f 72 6c 64        |Hello...World|
0000000e
```

在这里，没有任何“文本”或“二进制”的区别，只有一串十六进制数字。
- 左侧的 `00000000` 是 **Offset（偏移量）**，告诉我们这是文件的第几个字节。
- 中间的 `48 65 6c 6c 6f...` 是真正的文件内容。
- 右侧的 `|Hello...World|` 是工具为了方便我们阅读而提供的 ASCII 映射。

如果你只需要纯粹的十六进制输出，可以使用 `xxd -p`：
```bash
xxd -p data.txt
# 输出：48656c6c6f00ff8899576f726c64
```

## 5. 总结：Linux 的本质

当你意识到：
- **文件 ≠ 文本**
- **文件 = Bytes**

很多东西会突然串起来：
- 为什么 Shell 可以用管道 (`|`) 连接所有东西？因为它们流动的都是 bytes。
- 为什么 `cat` 也能显示图片内容（虽然是乱码）？因为它只是把 bytes 搬运到屏幕。
- 为什么 `.txt` 后缀在 Linux 下其实不重要？因为决定文件性质的是内容本身。

Unix 哲学中“万物皆文件”的背后，其实就是“万物皆字节流”。掌握了 `strings`、`hexdump` 和 `xxd`，你就拥有了看透二进制迷雾的“真理之眼”。
