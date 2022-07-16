---
title: 控制 eBPF Map
date: 2021-12-01 16:09
modify: 2021-12-01 16:31:42
author: edony.zpc
tags: 001-computer-technology ebpf/Map/ops
---


# 控制 eBPF Map
头文件 `linux/bpf_types.h` 中可以发现，不同的 Map 的操作，是由 `bpf_map_ops` 结构所引用的不同函数指针实现的。不过对于BPF开发者来说，所有Map都可以在eBPF或用户空间程序中，通过 `bpf_map_lookup_elem()` 和 `bpf_map_update_elem()` 函数访问。
```c

BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_ARRAY, percpu_array_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PROG_ARRAY, prog_array_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERF_EVENT_ARRAY, perf_event_array_map_ops)
#ifdef CONFIG_CGROUPS
BPF_MAP_TYPE(BPF_MAP_TYPE_CGROUP_ARRAY, cgroup_array_map_ops)
#endif
#ifdef CONFIG_CGROUP_BPF
BPF_MAP_TYPE(BPF_MAP_TYPE_CGROUP_STORAGE, cgroup_storage_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_CGROUP_STORAGE, cgroup_storage_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_HASH, htab_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_HASH, htab_percpu_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_LRU_HASH, htab_lru_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_LRU_PERCPU_HASH, htab_lru_percpu_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_LPM_TRIE, trie_map_ops)
#ifdef CONFIG_PERF_EVENTS
BPF_MAP_TYPE(BPF_MAP_TYPE_STACK_TRACE, stack_trace_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY_OF_MAPS, array_of_maps_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_HASH_OF_MAPS, htab_of_maps_map_ops)
#ifdef CONFIG_NET
BPF_MAP_TYPE(BPF_MAP_TYPE_DEVMAP, dev_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_DEVMAP_HASH, dev_map_hash_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_SK_STORAGE, sk_storage_map_ops)
#if defined(CONFIG_BPF_STREAM_PARSER)
BPF_MAP_TYPE(BPF_MAP_TYPE_SOCKMAP, sock_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_SOCKHASH, sock_hash_ops)
#endif
#ifdef CONFIG_BPF_LSM
BPF_MAP_TYPE(BPF_MAP_TYPE_INODE_STORAGE, inode_storage_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_CPUMAP, cpu_map_ops)
#if defined(CONFIG_XDP_SOCKETS)
BPF_MAP_TYPE(BPF_MAP_TYPE_XSKMAP, xsk_map_ops)
#endif
#ifdef CONFIG_INET
BPF_MAP_TYPE(BPF_MAP_TYPE_REUSEPORT_SOCKARRAY, reuseport_array_ops)
#endif
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_QUEUE, queue_map_ops)
BPF_MAP_TYPE(BPF_MAP_TYPE_STACK, stack_map_ops)
#if defined(CONFIG_BPF_JIT)
BPF_MAP_TYPE(BPF_MAP_TYPE_STRUCT_OPS, bpf_struct_ops_map_ops)
#endif
BPF_MAP_TYPE(BPF_MAP_TYPE_RINGBUF, ringbuf_map_ops)
```

## References
1. [bpf_types.h - include/linux/bpf_types.h - Linux source code (v5.10.82) - Bootlin](https://elixir.bootlin.com/linux/v5.10.82/source/include/linux/bpf_types.h#L81)