---
title: Rust packge
date: 2021-09-24 20:53
modify: 星期五 24日 九月 2021 20:53:03
author: edony.zpc
tags: 001-computer-technology
---

# Rust packge
## Rust package
_包_（_package_） 是提供一系列功能的一个或者多个 crate。一个包会包含有一个 _Cargo.toml_ 文件，阐述如何去构建这些 crate。

## Rust package规则
- 一个*包*中至多 **只能** 包含一个库 crate(library crate)；
- *包*中可以包含任意多个二进制 crate(binary crate)；
- *包*中至少包含一个 crate，无论是库的还是二进制的。

```text
$ cargo new my-project
     Created binary (application) `my-project` package
$ ls my-project
Cargo.toml
src
$ ls my-project/src
main.rs

```
## References
1. [包和 crate](https://kaisery.github.io/trpl-zh-cn/ch07-01-packages-and-crates.html)