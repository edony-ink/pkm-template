---
title: Rust Crate
date: 2021-09-24 20:59
modify: 星期日 26日 九月 2021 12:30:17
author: edony.zpc
tags: 001-computer-technology
---


# Rust Crate

## Crate和Package的关系
_包_（_package_） 是提供一系列功能的一个或者多个 crate。一个包会包含有一个 _`Cargo.toml`_ 文件，阐述如何去构建这些 crate。

## Crate规则
包中所包含的内容由几条规则来确立。一个包中至多 **只能** 包含一个库 crate(library crate)；包中可以包含任意多个二进制 crate(binary crate)；包中至少包含一个 crate，无论是库的还是二进制的。

## 理解Crate
- Package的子集是Crate
- Crate有两种形态：binary和library
- library crate最多一个，binary crate可以有多个

## References
1. [包和crate](https://kaisery.github.io/trpl-zh-cn/ch07-01-packages-and-crates.html)