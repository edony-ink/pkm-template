---
title: BPF-BPF calls
date: 2021-09-28 17:49
modify: 星期二 28日 九月 2021 17:49:22
author: edony.zpc
tags: 001-computer-technology ebpf/child_bpf_call
---

# BPF-BPF calls
BPF-BPF 调用是一个新添加的特性。在此特性引入之前，典型的BPF C 程序需要将所有可重用的代码声明为 always_inline 的，这样才能确保 LLVM 生成的 object 包含所有函数。这会导致函数在每个 object 文件中都反复（只要它被调用超过一次）出现，增加体积。

总是需要内联的原因是 BPF 的 Loader/Verifier/Interpreter/JITs 不支持函数调用。但是从内核4.16和 LLVM 6.0开始，此限制消除，BPF程序不再总是需要 always_inline。上面程序的 `__inline` 可以去掉了。

目前 x86_64/arm64 的 JIT 编译器支持 BPF to BPF 调用，这是很重要的性能优化，因为它大大简化了生成的 object 文件的尺寸，对 CPU 指令缓存更加友好。

JIT编译器为每个函数生成独立的映像（Image），并且在JIT的最后一个步骤中修复映像中的函数调用地址。

到5.9为止，你不能同时使用 BPF-BPF 调用（BPF 子程序）和尾调用。从5.10开始，可以混合使用，但是仍然存在一些限制。此外，混合使用两者可能导致内核栈溢出，原因是尾调用在跳转之前仅会 unwind 当前栈帧。

## References
1. 