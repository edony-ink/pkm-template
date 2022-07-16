---
title: Lifetime of BPF Objects
date: 2021-10-20 15:09
modify: 星期三 20日 十月 2021 15:09:23
author: edony.zpc
tags: 001-computer-technology ebpf/lifetime
---

# Lifetime of BPF Objects

BPF 对象有如下几个：
1. BPF progs（BPF 程序）
2. BPF maps
3. BPF debuginfo

## 使用 BPF Objects
用户态通过文件描述符来使用 BPF Objects，每个 Objects 都有引用计数。以 BPF Map 举例：
1. 用户态调用 `bpf_create_map()` 在 kernel 中分配 `struct bpf_map` 对象；
2. kernel 将该 `struct bpf_map` 对象的引用计数 `refcnt` 加1；
3. `bpf_create_map()` 执行成功之后返回一个文件描述符 `fd` 给用户态；
4. 用户态进程退出（正常或异常），`fd` 被关闭，引用计数 `refcnt` 减1，如果引用计数为0会触发 `RCU` 内存回收；

## BPF 程序
BPF 程序使用 BPF map的时候分为两个步骤：
1. 创建 BPF map，返回的 `fd` 被保存到 BPF 程序结构体的 `imm` 字段中（BPF_LD_IMM64 指令）。kernel 检测 BPF 程序通过之后，map 引用计数加1，所以用户态在关闭该 map 的 `fd` 的时候，这个 map 因为有 BPF 程序的引用计数，所以不会被内存回收，如果 BPF 程序的 `fd` 被关闭了，此时如果 map 的引用计数归0则会触发 map 内存回收。
2. BPF 程序被 attach 到 hook 点的时候，BPF 程序的引用计数会加1，此时用户态创建该 BPF 程序的进程可以退出了。此时被用户态创建的 BPF 程序会被 kernel 保证一直“活着”直到 BPF 程序的引用计数为0才会“死掉”。

另外需要注意的是，BPF 程序 attach 的点并不是都一样，XDP、tc、lwt、cgroup-based 等的 hook 点是全局的。

## BPF 文件系统
BPF 文件系统可以通过任意的名字将 BPF 程序或者 map “pin” 到 BPF 文件系统中。在 BPF 文件系统中 “pin” BPF 对象会是的引用计数加1，从而能够让 kernel 对 BPF 对象进行“保活”。

## BPF detach
BPF 生命周期还有个 detach 的概念，detach 勾子会阻止所有已经 attach 的 BPF 程序。

## BPF replace
cgroup-bpf 勾子是允许 BPF 程序进行替换的：
> The kernel guarantees that one of the old or new program will be processing events, but there is a window where it's possible that old program is executing on one CPU and new program for the same hook is executing on another CPU. There is no “atomic” replacement.

## References
1. [Lifetime of BPF objects · BPF](https://facebookmicrosites.github.io/bpf/blog/2018/08/31/object-lifetime.html)