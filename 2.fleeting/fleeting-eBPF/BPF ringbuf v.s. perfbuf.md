---
title: BPF ringbuf v.s. perfbuf
date: 2021-11-01 14:03
modify: 星期一 1日 十一月 2021 14:03:26
author: edony.zpc
tags: 001-computer-technology ebpf/ringbuffer
---

# BPF ringbuf v.s. perfbuf
## Memory overhead
### perfbuf
==perfbuf allocates a separate buffer for each CPU.== 

This often means that BPF developers have to make a trade off between allocating big enough per-CPU buffers (accommodating possible spikes of emitted data) or being memory-efficient (by not wasting unnecessary memory for mostly empty buffers in a steady state, but dropping data during data spikes). This is especially tricky for applications that have big swings between being mostly idle most of the time, but going through periodic big influx of events produced in a short period of time. It's quite hard to find just the right balance, so BPF applications would typically either over-allocate perfbuf memory to be on the safe side, or will suffer inevitable data drops from time to time.

### ringbuf
==ringbuf allows using one big common buffer to deal with memory issue by being shared across all CPUS.==

Bigger buffer can absorb bigger spikes, but also might allow using less RAM overall, compared to BPF perfbuf. BPF ringbuf memory usage also scales better with increased amount of CPUs, because going from 16 to 32 CPUs doesn’t necessarily require twice as big a buffer to accommodate more load. With BPF perfbuf, you would have little choice in this matter, unfortunately, due to per-CPU buffers.

## Event ordering
### perfbuf
If a BPF application has to track correlated events (e.g., process start and exit, network connection lifetime events, etc), proper ordering of events becomes critical. This is problematic with BPF perfbuf, though. If correlated events happen in rapid succession (within a few milliseconds) on different CPUs, they might get delivered out of order. This is, again, due to the per-CPU nature of BPF perfbuf.

### ringbuf
BPF ringbuf, which solves this problem by emitting events into a shared buffer and guarantees that if event A was submitted before event B, then it will be also consumed before event B. This often will noticeably simplify handling logic.

## Wasted work and extra data copying
### perfbuf
With BPF perfbuf, BPF program has to prepare a data sample, before copying it into perf buffer to send to user-space. This means that the same data has to be copied twice: first into a local variable or per-CPU array (for big samples that can’t fit on a small BPF stack), and then into perfbuf itself. What's worse, all this work could be wasted if it turns out that perfbuf doesn't have enough space left in it.

### ringbuf
BPF ringbuf supports an alternative reservation/submit API to avoid this. It’s possible to first reserve the space for data. If reservation succeeds, the BPF program can use that memory directly for preparing a data sample. Once done, submitting data to user-space is an extremely efficient operation that can't possibly fail and doesn't perform any extra memory copies at all. If reservation failed due to running out of space in a buffer, at least you know this before you’ve spent all that work trying to record the data, just to be later dropped on the floor. `ringbuf-reserve-commit` example below will show what that looks like in practice.

## Performance and applicability
BPF perfbuf, theoretically, can support higher throughput of data due to per-CPU buffers, but this becomes relevant only when we are talking about millions of events per second. But experiments with writing a real-world high-throughput application confirmed that BPF ringbuf is still a more performant replacement for BPF perfbuf, if used (similarly to BPF perfbuf) as a per-CPU buffer. Especially, if employing manual data availability notification. You can check out basic multi-ringbuf example (BPF side, user-space side) in one of kernel selftests. We'll look at an example of manual control over data availability notification a bit later.

==The only case where you might need to be careful and experiment first is when a BPF program has to run from NMI (non-maskable interrupt) context (e.g., for handling perf events, such as cpu-cycles). BPF ringbuf internally uses a very lightweight spin-lock, which means that data reservation might fail, if lock is contended in NMI context. So in NMI context, if CPU contention is high, there might be some data drops even when ringbuf itself still has some space available.==

In all other cases it is a pretty clear choice in favor of the new BPF ringbuf. BPF ringbuf provides a better performance and memory efficiency, better ordering guarantees, and better API (both kernel-side and in user-space).

## References
1. [BPF ring buffer](https://nakryiko.com/posts/bpf-ringbuf/)