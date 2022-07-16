---
title: Rust包管理
date: 2021-09-24 20:03
modify: 星期五 24日 九月 2021 20:52:04
author: edony.zpc
tags: 001-computer-technology
---

# Rust包管理
## 包管理目的
1. 功能分组

	伴随着项目的增长，你可以通过将代码分解为多个模块和多个文件来组织代码。一个包可以包含多个二进制 crate 项和一个可选的 crate 库。伴随着包的增长，你可以将包中的部分代码提取出来，做成独立的 crate，这些 crate 则作为外部依赖项。
2. 封装实现

	封装实现细节可以使你更高级地重用代码：你实现了一个操作后，其他的代码可以通过该代码的公共接口来进行调用，而不需要知道它是如何实现的。你在编写代码时可以定义哪些部分是其他代码可以使用的公共部分，以及哪些部分是你有权更改实现细节的私有部分。

## 包管理系统
-   **包**（_Packages_）： Cargo 的一个功能，它允许你构建、测试和分享 crate。
-   **Crates** ：一个模块的树形结构，它形成了库或二进制项目。
-   **模块**（_Modules_）和 **use**： 允许你控制作用域和路径的私有性。
-   **路径**（_path_）：一个命名例如结构体、函数或模块等项的方式

## References
1. [使用包、Crate 和模块管理不断增长的项目](https://kaisery.github.io/trpl-zh-cn/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html)