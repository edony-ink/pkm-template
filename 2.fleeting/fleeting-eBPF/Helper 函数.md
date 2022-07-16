---
title: Helper 函数
date: 2021-09-28 16:09
modify: 星期二 28日 九月 2021 16:09:16
author: edony.zpc
tags: 001-computer-technology
---

# Helper函数
BPF程序在hook点被调用，BPF执行的时候可以调用 helper 函数，helper 函数可以做很丰富的事情（当然可以自己开发）：
-   Search, update, and delete key-value pairs in tables
-   Generate a pseudo-random number
-   Collect and flag tunnel metadata
-   Chain eBPF programs together, known as tail calls
-   Perform tasks with sockets, like binding, retrieve cookies, redirect packets, etc.

BPF helper函数是有内核定义的，目前支持的BPF程序可以参考：[bpf-helpers(7) - Linux manual page](https://man7.org/linux/man-pages/man7/bpf-helpers.7.html)

### Helper函数签名
BPF Helper函数签名是统一的，具体函数签名如下所示：

`u64 fn(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)`

### Helper函数调用
内核将Helper函数抽象为 `BPF_CALL_0()` 到 `BPF_CALL_5()`的宏，这样用法可以保持跟syscall类似。
示例代码如下所示：
```c
BPF_CALL_4(bpf_map_update_elem, struct bpf_map *, map, void *, key,
           void *, value, u64, flags)
{
    WARN_ON_ONCE(!rcu_read_lock_held());
    return map->ops->map_update_elem(map, key, value, flags);
}

const struct bpf_func_proto bpf_map_update_elem_proto = {
    .func           = bpf_map_update_elem,
    .gpl_only       = false,
    .ret_type       = RET_INTEGER,
    .arg1_type      = ARG_CONST_MAP_PTR,
    .arg2_type      = ARG_PTR_TO_MAP_KEY,
    .arg3_type      = ARG_PTR_TO_MAP_VALUE,
    .arg4_type      = ARG_ANYTHING,
};
```

## References
1. 