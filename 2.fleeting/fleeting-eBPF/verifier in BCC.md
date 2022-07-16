---
title: verifier in BCC
date: 2021-12-14 17:24:04
modify: 2021-12-14 17:28:07
author: edony.zpc
tags: 001-computer-technology ebpf/BCC
---

# verifier in BCC
[BCC code](https://github.com/iovisor/bcc/tree/master/src/cc) 中可以看出来 BCC 没有做特别多跟 verifier 有关系的事情，还是借助了 libbpf 做 load 进而借助 linux bpf verifier 进行检测。

## References
1. [iovisor/bcc: BCC - Tools for BPF-based Linux IO analysis, networking, monitoring, and more](https://github.com/iovisor/bcc)