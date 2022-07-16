---
title: eBPF Maps
date: 2021-09-28 16:32
modify: 星期二 28日 九月 2021 16:32:09
author: edony.zpc
tags: 001-computer-technology
---

# eBPF Maps
![[Pasted image 20210928163238.png]]

eBPF Maps 是一个内核态的 K/V 存储，用于 BPF 程序之间共享状态或者用户态共享数据（文件描述符的方式访问）。

## Map 类型
### 通用 Map
通用 Map 所有的 Helper 程序都能使用，已有的通用 Map：
- `BPF_MAP_TYPE_HASH`
- `BPF_MAP_TYPE_ARRAY`
- `BPF_MAP_TYPE_PERCPU_HASH`
- `BPF_MAP_TYPE_PERCPU_ARRAY`
- `BPF_MAP_TYPE_LRU_HASH`
- `BPF_MAP_TYPE_LRU_PERCPU_HASH`
- `BPF_MAP_TYPE_LPM_TRIE`

### 非通用 Map
非通用 Map 是特定 Helper 函数专用的 Map，目前已有的 Map：
- `BPF_MAP_TYPE_PROG_ARRAY`
- `BPF_MAP_TYPE_PERF_EVENT_ARRAY`
- `BPF_MAP_TYPE_CGROUP_ARRAY`
- `BPF_MAP_TYPE_STACK_TRACE`
- `BPF_MAP_TYPE_ARRAY_OF_MAPS`
- `BPF_MAP_TYPE_HASH_OF_MAPS`
## References
1. 