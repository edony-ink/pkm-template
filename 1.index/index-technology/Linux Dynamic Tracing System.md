---
title: Linux Dynamic Tracing System
date: 2021-09-14 12:46
modify: 星期六 18日 九月 2021 11:30:59
author: edony.zpc
tags: 001-computer-technology
---

# Linux Dynamic Tracing System

## 1 Understand Tracing
1. [[Tracing是做什么的]]
2. [[为什么需要Tracing]]
3. [[Tracing是做什么的#Tracing类型|Tracing在哪些场景起作用]]
4. [[Tracing历史演进]]
5. [[Tracing技术架构]]
6. [[Tracing 大图]]
7. [[Tracing 分类]]
8. [[常见Tracing]]

## 2 Tracing data source
### 2.1. [[probes]]
1. [[probes#kprobes是什么|kprobes是什么]]
2. [[probes#kprobes原理|kprobes原理]]
3. [[probes#kprobes架构|kprobes架构]]
4. [[probes#kprobes example|kprobes样例]]
5. [[probes#^b0ee10|uprobes]]
6. [[probes#^b0ee10|理解uprobes]]

### 2.2. [[tracepoints]]
1. [[tracepoints#USDT|USDT]]
2. [[tracepoints#kernel tracepoints|kernel tracepoints]]
3. [[tracepoints#others|lttng-ust]]

### 2.3. [[probe和tracepoint的区别]]

## 3 Tracing data collecting mechanism
### 3.1. [[ftrace|ftrace数据收集机制]]
1. [[ftrace#ftrace原理|ftrace原理]]
2. [[ftrace#ftrace使用|ftrace使用]]
3. [[ftrace#ftrace demo|ftrace demo]]

### 3.2. [[perf_event|perf_event数据收集机制]]
1. [[perf_event#perf_event原理|perf_event原理]]
2. [[perf_event#perf_event使用|perf_event使用]]
3. [[perf_event#perf_event demo|perf_event demo]]

### 3.3. [[eBPF#4 eBPF 数据收集机制|eBPF 数据收集机制]]

### 3.4. [[systemtap]]

### 3.5. [[lttng|lttng数据收集机制]]
1. [[lttng-modules#^d71912|lttng原理]]

## 4 [[Tracing tools]]
