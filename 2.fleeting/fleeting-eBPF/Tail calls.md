---
title: Tail calls
date: 2021-09-28 17:33
modify: 星期二 28日 九月 2021 17:33:08
author: edony.zpc
tags: 001-computer-technology ebpf/tail_call
---

# Tail calls
尾调用允许一个BPF程序调用另外一个，这种调用没有函数调用那样的开销。其实现方式是long jump，重用当前stack frame。

注意：只用相同类型的BPF程序才能相互尾调用。

要使用尾调用，需要一个BPF_MAP_TYPE_PROG_ARRAY类型的Map，其内容目前必须由用户空间产生，值是需要被尾调用的BPF程序的文件描述符。通过助手函数bpf_tail_call触发尾调用，内核会将此调用内联到一个特殊的BPF指令。

## References
1. 