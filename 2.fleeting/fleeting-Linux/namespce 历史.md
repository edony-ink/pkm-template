---
title: namespce 历史
date: 2021-12-11 22:10:54
modify: 2021-12-11 22:11:06
author: edony.zpc
tags: 001-computer-technology linux/namespace/history
---

# namespce 历史
## Plan 9
namespace 的早期提出及使用要追溯到 Plan 9 from Bell Labs ，贝尔实验室的 Plan 9。这是一个分布式操作系统，由贝尔实验室的计算科学研究中心在八几年至02年开发的（02年发布了稳定的第四版，距离92年发布的第一个公开版本已10年打磨），现在仍然被操作系统的研究者和爱好者开发使用。在 Plan 9 的设计与实现中，我们着重提以下3点内容：
- 文件系统：所有系统资源都列在文件系统中，以 Node 标识。所有的接口也作为文件系统的一部分呈现。
- Namespace：能更好的应用及展示文件系统的层次结构，它实现了所谓的 “分离”和“独立”。
- 标准通信协议：9P协议（Styx/9P2000）。

## 进入 Linux kernel
Namespace 开始进入 Linux Kernel 的版本是在 2.4.X，最初始于 2.4.19 版本。但是，自 2.4.2 版本才开始实现每个进程的 namespace。

## Linux kernel 3.8 基本实现
Linux 3.8 中终于完全实现了 User Namespace 的相关功能集成到内核。这样 Docker 及其他容器技术所用到的 namespace 相关的能力就基本都实现了。

## References
1. [容器技术的基石-namespace](https://moelove.info/2021/12/10/搞懂容器技术的基石-namespace-上/)