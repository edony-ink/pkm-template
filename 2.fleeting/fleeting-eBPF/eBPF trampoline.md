---
title: eBPF trampoline
date: 2021-10-26 14:28
modify: 星期二 26日 十月 2021 14:28:50
author: edony.zpc
tags: 001-computer-technology
---


# eBPF trampoline
Note：目前对这一块的理解不是特别清晰，以下内容摘选自绪峰的整理。

BPF trampoline的目标是把bpf程序的调用从间接跳转转换为直接跳转，基本的思路就是以空间换取时间。

首先来看下数据结构的组织，见下图所示:
![[Pasted image 20211026164231.png]]

BPF trampoline实现机制的顶层是以hash表的形式组织的，一共有1024个hash bucket，hash表存储的每个元素通过bpf_trampoline结构体定义，如上图所示，里面最重要的是'image'字段，它就是trampoline机制产生的机器指令码，每个image指向一个PAGE_SIZE大小的空间，也就是4K，但是里面只有2K的空间被真正使用，另外2K是预留的空间，从commit log描述可见，该预留的空间主要为了防止bpf程序detach阶段的内存分配失败使用的。由于只有2K的空间是为trampoline使用的，因而当前限制每个image最多只能为38个bpf程序做trampoline调用：
```c
/* Each call __bpf_prog_enter + call bpf_func + call __bpf_prog_exit is ~50
 * bytes on x86.  Pick a number to fit into BPF_IMAGE_SIZE / 2
 */
#define BPF_MAX_TRAMP_PROGS 38
```

下面看一下trampoline指令代码的生成过程:

```c
bpf() syscall --->
  bpf_raw_tracepoint_open() --->
    bpf_tracing_prog_attach() --->
      bpf_trampoline_link_prog() --->
        bpf_trampoline_update() --->
          arch_prepare_bpf_trampoline() --->
            invoke_bpf()
          register_fentry()
```

bpf_trampoline数据结构的内存分配是在bpf程序load的时刻创建的(最新的代码在bpf prog attach的时刻也可能会创建trampoline结构，还没太理解这里面的逻辑)，verifier会自动创建bpf_trampoline内存并针对load的bpf程序做相应的初始化，在bpf程序attach的时候，会通过调用架构相关的arch_prepare_bpf_trampoline()函数(在arch/x86/net/bpf_jit_comp.c实现)填充trampoline image的执行指令，然后修改原始被attached的内核函数入口指令地址到trampoline地址(在register_fentry()实现)，最后，attach点内核函数被触发的时候，会首先执行trampoline的代码，从而执行attach的bpf程序，trampoline的指令代码充当了内核代码和bpf程序的桥梁作用，加速相互之间的调用。另外，需要注意的是，为了保持最好的性能，BPF trampoline的指令代码(image)是在每次bpf程序attach/detach的时候都要重新生成的。

## References
1. [BPF trampoline简介](https://ata.alibaba-inc.com/articles/199228)