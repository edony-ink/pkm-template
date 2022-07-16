---
title: 钉住 eBPF Map
date: 2021-12-01 15:54
modify: 2021-12-01 16:08:10
author: edony.zpc
tags: 001-computer-technology ebpf/Map/pin
---


# 钉住 eBPF Map
所谓 eBPF Map pin 是指通过文件系统路径来暴露 Map，目前有两种方式 pin 住 Map：
## 1. Map 定义 pin 参数
如果使用了 `struct bpf_elf_map` 定义 Map section，可以指定其中的 `pinning` 字段：
```c
struct {
    __uint(type, BPF_MAP_TYPE_LPM_TRIE);
    __uint(max_entries, 16384);
    __type(key, directory_rule_key_t);
    __type(value, directory_rule_value_t);
    __uint(map_flags, BPF_F_NO_PREALLOC);
    __uint(pinning, LIBBPF_PIN_BY_NAME);
} pangolin_directory_rule_map SEC(".maps");
```

## 2. bpf_obj_pin 
手工调用 libbpf 钉住 Map： `bpf_obj_pin(fd, path)`。其它程序可以调用 `mapfd = bpf_obj_get(pinned_file_path);` 获得 Map 的文件描述符。

## References
1. [绿色记忆:eBPF学习笔记](https://blog.gmem.cc/ebpf)