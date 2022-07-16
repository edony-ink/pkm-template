---
title: Tracing 分类
date: 2021-12-02 15:53
modify: 2021-12-02 16:00:51
author: edony.zpc
tags: 001-computer-technology tracing/kinds tracing/dynamic tracing/static
---


# Tracing 分类
## 1 动态 tracing
> nserting instrumentation points into live software (e.g. in production)

### 1.1 kprobes/kretprobes
dynamic instrumentation for kernel-level functions
#### kprobes
fire when execution hits the beginning of the target kernel function being traced
#### kretprobes
fire when execution returns from the target kernel function being traced
 
### 1.2 uprobes/uretprobes
dynamic instrumentation for userspace-level C functions
#### uprobes
fire when execution hits the beginning of the target userspace C function
#### uretprobes
fire when execution returns from the target userspace C function

### 1.3 优缺点分析
- 优点: zero overhead when not in use, no recompiling or rebuilding needed
- 缺点: functions can be renamed or removed from one software version to the next (interface stability issue), no visibility on inline'd functions

## 2 静态 tracing
### 2.1 Kernel Tracepoints
static instrumentation for kernel-level code
- Currently defined kernel tracepoints for a Linux machine can be found in /sys/kernel/debug/tracing/events/*
- Define new kernel tracepoints in include/trace/events
 
### 2.2 USDT Tracepoints
static instrumentation for userspace-level C code
- Also known as USDT probes, user markers, userspace tracepoints, etc.
- Can be added to an application using headers and tools from the systemtap-sdt-dev package, or with custom headers

### 2.3 优缺点分析
- 优点: can be placed anywhere in code (including inline'd functions), high visibility on variables (including structs), more stable API
- 缺点: many defined tracepoints can become a maintenance burden, requires recompile/rebuild to add new tracepoints, non-zero overhead for disabled tracepoints (nop instruction at tracepoint)

## References
1. [Intro to Kernel and Userspace Tracing Using BCC, Part 1 of 3](https://blogs.oracle.com/linux/post/intro-to-bcc-1)