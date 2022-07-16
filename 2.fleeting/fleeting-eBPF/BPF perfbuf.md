---
title: BPF perfbuf
date: 2021-11-01 11:37
modify: 星期一 1日 十一月 2021 11:37:59
author: edony.zpc
tags:  001-computer-technology ebpf/ringbuffer ebpf/perfbuf
---

# BPF perfbuf
a kernel object, so-called perfbuf it is a FIFO event queue between kernel space and user space. Perfbuf is a collection of per-CPU circular buffers, which allows to efficiently exchange data between kernel and user-space. It works great in practice, but due to its per-CPU design it has two major short-comings that prove to be inconvenient in practice: inefficient use of memory and event re-ordering.

Let eBPF output data to perf sample event which add an extra perf trace buffer for other utilities like bpf to fill extra data to perf events.

## References
1. [tezedge/tezedge-firewall: Tezos firewall using BPF and XDP](https://github.com/tezedge/tezedge-firewall)
2. [Make eBPF programs output data to perf event [LWN.net]](https://lwn.net/Articles/649965/)