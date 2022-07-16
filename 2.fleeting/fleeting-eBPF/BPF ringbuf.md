---
title: BPF ringbuff
date: 2021-11-01 13:45
modify: 星期一 1日 十一月 2021 13:45:16
author: edony.zpc
tags: 001-computer-technology ebpf/ringbuffer ebpf/ringbuf
---

# BPF ringbuf
starting from Linux 5.8, BPF provides a new BPF data structure (BPF map): BPF ring buffer (ringbuf). It is a multi-producer, single-consumer (MPSC) queue and can be safely shared across multiple CPUs simultaneously.

BPF ringbuf support a familiar functionality from BPF perfbuf:

- variable-length data records;
- ability to efficiently read data from user-space through memory-mapped region without extra memory copying and/or syscalls into the kernel;
- both epoll notifications support, as well as an ability to busy-loop for the absolutely minimal latency.

At the same time, BPF ringbuf solves the following issues with BPF perfbuf:

- memory overhead;
- data ordering;
- wasted work and extra data copying.



## References
1. [BPF ring buffer](https://nakryiko.com/posts/bpf-ringbuf/)