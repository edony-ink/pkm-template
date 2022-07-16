---
title: Rust 关注分离原则
date: 2021-09-27 15:41
modify: 星期一 27日 九月 2021 15:41:54
author: edony.zpc
tags: 001-computer-technology
---

# Rust 关注分离原则
`main` 函数负责多个任务的组织问题在许多二进制项目中很常见。所以 Rust 社区开发出一类在 `main` 函数开始变得庞大时进行二进制程序的关注分离的指导性过程。这些过程有如下步骤：

-   将程序拆分成 _main.rs_ 和 _lib.rs_ 并将程序的逻辑放入 _lib.rs_ 中。
-   当命令行解析逻辑比较小时，可以保留在 _main.rs_ 中。
-   当命令行解析开始变得复杂时，也同样将其从 _main.rs_ 提取到 _lib.rs_ 中。

经过这些过程之后保留在 `main` 函数中的责任应该被限制为：

-   使用参数值调用命令行解析逻辑
-   设置任何其他的配置
-   调用 _lib.rs_ 中的 `run` 函数
-   如果 `run` 返回错误，则处理这个错误

这个模式的一切就是为了关注分离：_main.rs_ 处理程序运行，而 _lib.rs_ 处理所有的真正的任务逻辑。因为不能直接测试 `main` 函数，这个结构通过将所有的程序逻辑移动到 _lib.rs_ 的函数中使得我们可以测试他们。仅仅保留在 _main.rs_ 中的代码将足够小以便阅读就可以验证其正确性。让我们遵循这些步骤来重构程序。

## References
1. [重构以改进模块化与错误处理](https://kaisery.github.io/trpl-zh-cn/ch12-03-improving-error-handling-and-modularity.html#%E4%BA%8C%E8%BF%9B%E5%88%B6%E9%A1%B9%E7%9B%AE%E7%9A%84%E5%85%B3%E6%B3%A8%E5%88%86%E7%A6%BB)