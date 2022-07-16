---
title: Tokio Overview
date: 2021-12-14 20:40:32
modify: 2021-12-14 20:40:32
author: edony.zpc
tags: 001-computer-technology Tokio/overview
---

# Tokio Overview
![[Pasted image 20211224160446.png]]
Tokio是用于Rust编程语言的一个异步运行时。它提供了编写网络应用所需的构建块。它提供了针对各种系统的灵活性，从有几十个内核的大型服务器到小型嵌入式设备。

## Tokio 优势
- Reliable/可靠：Tokio 的 API 是内存安全和线程安全的，并且是抗误操作的。这有助于防止常见的错误，如无界队列、缓冲区溢出和任务饿死。
- Fast/快速：构建在Rust之上，Tokio提供了一个多线程的、抢占式的调度器。应用程序可以每秒处理数十万个请求，而且开销很小。
- Easy/简单：async/await 减少了编写异步应用程序的复杂性。与Tokio的实用工具和充满活力的生态系统相配，编写应用程序是一件轻而易举的事。
- Flexible/弹性：服务器应用程序的需求与嵌入式设备的需求不同。尽管Tokio带有默认值可以开箱即用，但它也提供了所需的旋钮，以便对不同的情况进行微调。

## Tokio 组件
- Runtime: Tokio运行时包括I/O、定时器、文件系统、同步和调度设施，是异步应用的基础。
- Hyper: Hyper是一个HTTP客户端和服务器库，同时支持HTTP 1和2协议。
- Tonic: 一个无固定规则（boilerplate-free）的gRPC客户端和服务器库。通过网络发布和使用API的最简单方法。
- Tower：用于建立可靠的客户端和服务器的模块化组件。包括重试、负载平衡、过滤、请求限制设施等。
- Mio：在操作系统的事件化I/O API之上的最小的可移植API。
- Tracing: 对应用程序和库的统一的洞察力。提供结构化的、基于事件的数据收集和记录。
- Bytes：在核心部分，网络应用程序操纵字节流。Bytes提供了一套丰富的实用程序来操作字节数组。

## Tokio 劣势
Tokio不适合的使用情况：
- 通过在几个线程上并行运行来加速由CPU控制的计算。Tokio是为IO绑定的应用而设计的，在这种情况下，每个单独的任务大部分时间都在等待IO。如果你的应用程序唯一做的事情是并行运行计算，你应该使用rayon。也就是说，如果你需要同时做这两件事，还是可以 “混合搭配” 的。
- 读取大量的文件。虽然看起来Tokio对那些仅仅需要读取大量文件的项目很有用，但与普通线程池相比，Tokio在这里没有提供任何优势。这是因为操作系统一般不提供异步文件API。
- 发送单个网络请求。Tokio给你带来优势的地方是当你需要同时做很多事情时。如果你需要使用一个用于异步Rust的库，如reqwest，但你不需要同时做很多事情，你应该选择该库的阻塞版本，因为它将使你的项目更简单。当然，使用Tokio仍然可以工作，但与阻塞式API相比，没有提供真正的优势。如果该库没有提供阻塞式的API，请看关于用同步代码桥接的章节。

## References
1. [Tutorial | Tokio - An asynchronous Rust runtime](https://tokio.rs/tokio/tutorial)
2. [Tokio概述 | Tokio学习笔记](https://skyao.io/learning-tokio/docs/introduction/tokio.html)
3. [Tokio教程概况 | Tokio学习笔记](https://skyao.io/learning-tokio/docs/tutorial/tutorial.html)