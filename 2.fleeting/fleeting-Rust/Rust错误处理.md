---
title: Rust错误处理
date: 2021-09-26 15:35
modify: 星期日 26日 九月 2021 15:36:00
author: edony.zpc
tags: 001-computer-technology
---

# Rust错误处理
Rust 要求你承认出错的可能性，并在编译代码之前就采取行动。这些要求使得程序更为健壮，它们确保了你会在将代码部署到生产环境之前就发现错误并正确地处理它们！

Rust 将错误组合成两个主要类别：**可恢复错误**（_recoverable_）和 **不可恢复错误**（_unrecoverable_）。可恢复错误通常代表向用户报告错误和重试操作是合理的情况，比如未找到文件。不可恢复错误通常是 bug 的同义词，比如尝试访问超过数组结尾的位置。

## References
1. [错误处理](https://kaisery.github.io/trpl-zh-cn/ch09-00-error-handling.html)
