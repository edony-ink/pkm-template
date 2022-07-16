---
title: 定义 eBPF Map
date: 2021-12-01 15:06
modify: 2021-12-01 15:54:21
author: edony.zpc
tags: 001-computer-technology ebpf/Map ebpf/Map/define ebpf/Map/load
---


# 定义 eBPF Map
## eBPF Map 定义
### libbpf/bpf_helpers.h
```c
/*
 * Helper structure used by eBPF C program
 * to describe BPF map attributes to libbpf loader
 */
struct bpf_map_def {
	unsigned int type;			// map 类型
	unsigned int key_size;		// map 键长度
	unsigned int value_size;	// map 值长度
	unsigned int max_entries;	// map 键值对数
	unsigned int map_flags;		// map 标记位
};
```
### iproute2/bpf_elf.h
```c
/* ELF map definition */
struct bpf_elf_map {
	__u32 type;
	__u32 size_key;
	__u32 size_value;
	__u32 max_elem;
	__u32 flags;
	__u32 id;
	__u32 pinning;
	__u32 inner_id;
	__u32 inner_idx;
};
```
> This alternative structure, called `bpf_elf_map`,
is compatible with the one provided by the kernel, and can be used by eBPF programs instead of
`bpf_map_def`. It exposes extra members, such as pinning which can be used to define the map
scope. This field can receive three distinct values: `PIN_GLOBAL_NS`, `PIN_OBJECT_NS`, and `PIN_NONE`.

这两种 Map 在加载器层面做了统一，都能够被 bpf syscall 识别。

## eBPF Map 实现
### Map 结构体定义
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

### Map 加载
BPF 加载器会扫描 BPF object 的 ELF 头以发现 Map 定义，并调用tools/lib/bpf/bpf.c 中的 `bpf_create_map_node()` 或 `bpf_create_map_in_map_node()` 来创建 Map。这两个函数实际上是调用 bpf 系统调用的 `BPF_MAP_CREATE` 命令。

## References
1. [Fast Packet Processing with eBPF and XDP: Concepts, Code, Challenges and Applications](https://homepages.dcc.ufmg.br/~mmvieira/so/papers/Fast_Packet_Processing_with_eBPF_and_XDP.pdf)
2. [绿色记忆:eBPF学习笔记](https://blog.gmem.cc/ebpf)
3. [For Developers - BPF and XDP Reference Guide - 《Cilium v1.9 Documentation》 - 书栈网 · BookStack](https://www.bookstack.cn/read/cilium-1.9-en/ef6762a4485df372.md)
4. [Exploring BPF ELF Loaders at the BPF Hackfest | Kinvolk](https://kinvolk.io/blog/2018/10/exploring-bpf-elf-loaders-at-the-bpf-hackfest/)