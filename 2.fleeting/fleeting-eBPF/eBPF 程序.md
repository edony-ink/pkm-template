---
title: eBPF 程序
date: 2021-10-25 16:18
modify: 星期一 25日 十月 2021 16:18:26
author: edony.zpc
tags: 001-computer-technology
---

# eBPF 程序
BPF 程序是内核可编程的最直接体现，`man bpf` 中关于 `BPF_PROG_TYPE` 的说明：
> The eBPF program type (prog_type) determines the subset of kernel helper functions that the program may call. The program type also determines the program input (con‐text)—the format of struct bpf_context (which is the data blob passed into the eBPF program as the first argument).

BPF 程序有几种类型：
```c
/* Note that tracing related programs such as

* BPF_PROG_TYPE_{KPROBE,TRACEPOINT,PERF_EVENT,RAW_TRACEPOINT}

* are not subject to a stable API since kernel internal data

* structures can change from release to release and may

* therefore break existing tracing BPF programs. Tracing BPF

* programs correspond to /a/ specific kernel which is to be

* analyzed, and not /a/ specific kernel /and/ all future ones.

*/

enum bpf_prog_type {

BPF_PROG_TYPE_UNSPEC,

BPF_PROG_TYPE_SOCKET_FILTER,

BPF_PROG_TYPE_KPROBE,

BPF_PROG_TYPE_SCHED_CLS,

BPF_PROG_TYPE_SCHED_ACT,

BPF_PROG_TYPE_TRACEPOINT,

BPF_PROG_TYPE_XDP,

BPF_PROG_TYPE_PERF_EVENT,

BPF_PROG_TYPE_CGROUP_SKB,

BPF_PROG_TYPE_CGROUP_SOCK,

BPF_PROG_TYPE_LWT_IN,

BPF_PROG_TYPE_LWT_OUT,

BPF_PROG_TYPE_LWT_XMIT,

BPF_PROG_TYPE_SOCK_OPS,

BPF_PROG_TYPE_SK_SKB,

BPF_PROG_TYPE_CGROUP_DEVICE,

BPF_PROG_TYPE_SK_MSG,

BPF_PROG_TYPE_RAW_TRACEPOINT,

BPF_PROG_TYPE_CGROUP_SOCK_ADDR,

BPF_PROG_TYPE_LWT_SEG6LOCAL,

BPF_PROG_TYPE_LIRC_MODE2,

BPF_PROG_TYPE_SK_REUSEPORT,

BPF_PROG_TYPE_FLOW_DISSECTOR,

BPF_PROG_TYPE_CGROUP_SYSCTL,

BPF_PROG_TYPE_RAW_TRACEPOINT_WRITABLE,

BPF_PROG_TYPE_CGROUP_SOCKOPT,

BPF_PROG_TYPE_TRACING,

BPF_PROG_TYPE_STRUCT_OPS,

BPF_PROG_TYPE_EXT,

BPF_PROG_TYPE_LSM,

BPF_PROG_TYPE_SK_LOOKUP,

BPF_PROG_TYPE_SYSCALL, /* a program that can execute syscalls */

};
```

## References
1. [linux/bpf.h at master · torvalds/linux](https://github.com/torvalds/linux/blob/master/include/uapi/linux/bpf.h)