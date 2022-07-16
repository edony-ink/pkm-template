---
title: BPF 与 event-driven
date: 2021-09-28 16:03
modify: 星期二 28日 九月 2021 16:03:12
author: edony.zpc
tags: 001-computer-technology
---

# BPF与event-driven
BPF程序在内核中执行都是事件驱动型的，例如我们将一个BPF程序attach到一个网络设备入口调用的地方，当网络设备接收到网络包的时候就会出发该BPF程序的执行。
BPF支持的事件有：
-   System Calls - Inserted when user space functions transfer execution to the kernel
-   Function Entry and Exit - Intercepts calls to pre-existing functions
-   Network Events - Executes when packets are received
-   Kprobes and uprobes - Attach to probes for kernel or user functions

## References
1. [A Gentle Introduction to eBPF](https://www.infoq.com/articles/gentle-linux-ebpf-introduction/)