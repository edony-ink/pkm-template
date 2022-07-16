---
title: verifier in ply
date: 2021-12-14 17:28:20
modify: 2021-12-14 17:35:53
author: edony.zpc
tags: 001-computer-technology
---

# verifier in ply
>ply follows the Little Language approach of yore, compiling ply scripts into Linux BPF programs that are attached to kprobes and tracepoints in the kernel. The scripts have a C-like syntax, heavily inspired by dtrace(1) and, by extension, awk(1).

通过查看 [ply code](https://github.com/iovisor/ply/blob/master/src/libply/aux/syscall.c) 直接调用裸的 bpf syscall 来完成 bpf 程序的生命周期管理，没有涉及到 verifier 相关的优化和改动。

## References
1. [iovisor/ply: Dynamic Tracing in Linux](https://github.com/iovisor/ply)
2. [ply](https://wkz.github.io/ply/)