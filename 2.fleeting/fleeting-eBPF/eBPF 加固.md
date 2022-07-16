---
title: eBPF 加固
date: 2021-11-26 17:30
modify: 星期五 26日 十一月 2021 17:30:42
author: edony.zpc
tags: 001-computer-technology ebpf/harden
---


# eBPF 加固
- Program execution protection: eBPF 程序加载完毕后，kernel 将设置 eBPF 程序为只读。
- Mitigation against Spectre: ==TODO: 这里不太理解==
- Constant blinding: 所有的 eBPF 程序常量在加载后 blinding，防止通过常量注入可执行代码，阻止 JIT 攻击。

## References
1. [ebpf 介绍](http://hushi55.github.io/2021/04/02/ebpf-introduction-2)
2. [迟到的Meltdown/Spectre分析](https://blog.csdn.net/21cnbao/article/details/109192951)