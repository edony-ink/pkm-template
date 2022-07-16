---
title: eBPF sysfs
date: 2021-10-25 16:38
modify: 星期一 25日 十月 2021 16:38:18
author: edony.zpc
tags: 001-computer-technology
---

# eBPF sysfs
BPF 程序和 BPF Maps 可以通过虚拟文件系统暴露给用户态，用户态读取和修改 BPF Map 的映射关系和数据。这个虚拟文件系统是通过 [[eBPF Objects pinning|pin]] 操作完成的，`pin` 住之后的 BPF 程序和 Maps 就可以一直运行而不跟随创建进程的生命周期。
