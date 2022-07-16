---
title: Rust范型和生命周期
date: 2021-09-26 16:27
modify: 星期日 26日 九月 2021 16:27:38
author: edony.zpc
tags: 001-computer-technology
---

# Rust范型和生命周期
每一个编程语言都有高效处理重复概念的工具。在 Rust 中其工具之一就是 **泛型**（_generics_）。泛型是具体类型或其他属性的抽象替代。我们可以表达泛型的属性，比如他们的行为或如何与其他泛型相关联，而不需要在编写和编译代码时知道他们在这里实际上代表什么。

## References
1. [泛型、trait 与生命周期](https://kaisery.github.io/trpl-zh-cn/ch10-00-generics.html)