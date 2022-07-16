---
title: Rust函数式性能
date: 2021-10-13 19:46
modify: 星期三 13日 十月 2021 19:46:48
author: edony.zpc
tags: 001-computer-technology
---

# Rust 函数式性能
我们运行了一个性能测试，通过将阿瑟·柯南·道尔的“福尔摩斯探案集”的全部内容加载进 `String` 并寻找其中的单词 “the”。如下是 `for` 循环版本和迭代器版本的 `search` 函数的性能测试结果：

```
test bench_search_for  ... bench:  19,620,300 ns/iter (+/- 915,700)
test bench_search_iter ... bench:  19,234,900 ns/iter (+/- 657,200)
``` 

结果迭代器版本还要稍微快一点！这里我们将不会查看性能测试的代码，我们的目的并不是为了证明他们是完全等同的，而是得出一个怎样比较这两种实现方式性能的基本思路。

对于一个更全面的性能测试，将会检查不同长度的文本、不同的搜索单词、不同长度的单词和所有其他的可变情况。这里所要表达的是：迭代器，作为一个高级的抽象，被编译成了与手写的底层代码大体一致性能代码。迭代器是 Rust 的 **零成本抽象**（_zero-cost abstractions_）之一，它意味着抽象并不会引入运行时开销，它与本贾尼·斯特劳斯特卢普（C++ 的设计和实现者）在 “Foundations of C++”（2012） 中所定义的 **零开销**（_zero-overhead_）如出一辙：
> In general, C++ implementations obey the zero-overhead principle: What you don’t use, you don’t pay for. And further: What you do use, you couldn’t hand code any better.
>
>  \- Bjarne Stroustrup "Foundations of C++"

## References
1. 