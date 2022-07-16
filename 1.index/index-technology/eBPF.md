---
title: eBPF
date: 2021-09-18 15:35
modify: 2021-12-14 20:46:27
author: edony.zpc
tags: 001-computer-technology
aliases: bpf
---

# eBPF
## 1. eBPF 原理
### 1.1 [[eBPF 架构]]
### 1.2 技术原理
#### 1.2.1 [[勾子原理]]
#### 1.2.2 [[BPF 与 event-driven]]
### 1.3 eBPF 基本组件
#### 1.3.1 [[Helper 函数]]
#### 1.3.2 [[eBPF Maps]]
#### 1.3.3 [[eBPF syscall]]
#### 1.3.4 [[eBPF Objects pinning]]
#### 1.3.5 [[Tail calls]]
#### 1.3.6 [[BPF-BPF calls]]
#### 1.3.7 [[BPF Verifier]]
#### 1.3.8 [[eBPF JIT]]
#### 1.3.9 [[eBPF 加固]]

## 2. eBPF 生命周期
### 2.1 [[Lifetime of BPF Objects]]
### 2.2 [[eBPF BTF]]

## 3. eBPF 理解使用
### 3.1 [[eBPF 编程]]
#### 3.1.1 [[eBPF 內联一切]]
#### 3.1.2 [[eBPF 段注释]]
#### 3.1.3 [[eBPF 使用内置函数]]
#### 3.1.4 [[eBPF 程序限制]]
#### 3.1.5 [[eBPF 尾调用]]
### 3.2 [[eBPF API]]
#### 3.2.1 [[eBPF helper]]
#### 3.2.2 [[eBPF syscall]]
#### 3.2.4 [[eBPF 程序]]
### 3.3 [[eBPF sysfs]]
### 3.4 [[eBPF trampoline]]
#### 3.4.1 [[eBPF trampoline 原理]]
#### 3.4.2 [[eBPF trampoline 改善]]
### 3.5 eBPF 程序关键逻辑
#### 3.5.1 [[BPF 程序关键逻辑——libbpf]]
#### 3.5.2 [[BPF 程序关键逻辑——LSM]]
#### 3.5.3 [[BPF 程序关键逻辑——tracing]]
### 3.6 eBPF ringbuffer
#### 3.6.1 [[BPF ringbuf]]
#### 3.6.2 [[BPF perfbuf]]
#### 3.6.3 [[BPF ringbuf v.s. perfbuf]]
#### 3.6.4 [[BPF ringbuffer APIs]]
#### 3.6.5 [[BPF ringbuffer demo]]
### 3.7 eBPF Map 操作
#### 3.7.1 [[定义 eBPF Map]]
#### 3.7.2 [[钉住 eBPF Map]]
#### 3.7.3 [[控制 eBPF Map]]
#### 3.7.4 [[Map 内部逻辑]]
### 3.8 [[eBPF helper 函数列表]]

## 4. eBPF 数据收集机制
### 4.1 [[eBPF tracing 架构]]
### 4.2 [[eBPF tracing 特性]]
### 4.3 [[ebpf tracing 源码阅读]]

## 5. eBPF demo

## 6. [[eBPF 生态]]
### 6.1 [[deep in eBPF]]

## 7. advanced eBPF verifier
### 7.1 eBPF verifier surroundings
#### 7.1.1 [[verifier in BCC]]
#### 7.1.2 [[verifier in ply]]
#### 7.1.3 [[verifier in bpftrace]]
#### 7.1.4 [[verifier in userspace]]
### 7.2 linux eBPF verifier 原理
#### 7.2.1 [[verifier in linux]]
#### 7.2.2 [[verifier detailed logic]]
#### 7.2.3 [[verifier CVE]]
### 7.3 verifier 优化
#### 7.3.1 用户态 verifier 调研
##### 1. [[uBPF]]
##### 2. [[rBPF]]
