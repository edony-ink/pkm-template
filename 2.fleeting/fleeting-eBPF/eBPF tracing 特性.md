---
title: eBPF tracing 特性
date: 2021-12-02 16:20
modify: 2021-12-02 16:22:38
author: edony.zpc
tags: 001-computer-technology ebpf/tracing_feature
---


# eBPF tracing 特性
- Dynamic tracing, kernel-level (BPF support for kprobes)
- Dynamic tracing, user-level (BPF support for uprobes)
- Static tracing, kernel-level (BPF support for kernel tracepoints)
- Timed sampling events (BPF with `perf_event_open()`)
- PMC events (BPF with `perf_event_open()`)
- Filtering (via. BPF programs)
- Debug output (`bpf_trace_printk()`)
- Per-event output (`bpf_perf_event_output()`)
- Basic variables (global and per-thread variables, via BPF maps)
- Associative arrays (via BPF maps)
- Frequency counting (via BPF maps)
- Histograms (power-of-two, linear, and custom; via BPF maps)
- Timestamps and time deltas (`bpf_ktime_get_ns()` and BPF programs)
- Stack traces - kernel (BPF stack map)
- Stack traces - userspace (BPF stack map)
- Overwrite ring buffers (`perf_event_attr.write_backward`)
- Low-overhead instrumentation (BPF JIT, BPF map summaries)
- Production safe (BPF verifier)

## References
1. [Intro to Kernel and Userspace Tracing Using BCC, Part 1 of 3](https://blogs.oracle.com/linux/post/intro-to-bcc-1)