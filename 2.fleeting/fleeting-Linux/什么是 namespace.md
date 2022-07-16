---
title: 什么是 namespace
date: 2021-12-11 21:57:23
modify: 2021-12-11 22:08:32
author: edony.zpc
tags: 001-computer-technology linux/namespace/what
---

# 什么是 namespace
> Namespaces are a feature of the Linux kernel that partitions kernel resources such that one set of processes sees one set of resources while another set of processes sees a different set of resources. The feature works by having the same namespace for a set of resources and processes, but those namespaces refer to distinct resources.

简单来说 namespace 是由 Linux 内核提供的，用于进程间资源隔离的一种技术。将全局的系统资源包装在一个抽象里，让进程（看起来）拥有独立的全局资源实例。同时 Linux 也默认提供了多种 namespace，用于对多种不同资源进行隔离。

## References
1. [linux namespace](https://en.wikipedia.org/wiki/Linux_namespaces)
2. [容器技术的基石-namespace](https://moelove.info/2021/12/10/搞懂容器技术的基石-namespace-上/)