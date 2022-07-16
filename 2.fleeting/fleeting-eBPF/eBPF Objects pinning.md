---
title: eBPF Objects pinning
date: 2021-09-28 17:17
modify: 星期二 28日 九月 2021 17:17:37
author: edony.zpc
tags: 001-computer-technology
---

# eBPF Objects pinning
## 背景问题
eBPF Maps 是通过 file descriptor 来进行访问的，而 file descriptor 的生命周期是跟进程有关系的，如果进程结束了，那么 fd 的有效性是有问题的，另外 eBPF Maps 的共享是 BPF 程序之间和用户态程序之间，这就导致 eBPF 程序设置 Maps 结束之后，用户态无法获取这个Maps。

## BPF_OBJ_PIN
> a minimal kernel space BPF file system has been implemented, where BPF map and programs can be pinned to, a process called object pinning. The BPF system call has therefore been extended with two new commands which can pin (`BPF_OBJ_PIN`) or retrieve (`BPF_OBJ_GET`) a previously pinned object.

![[Pasted image 20210928173157.png]]

## References
1. 