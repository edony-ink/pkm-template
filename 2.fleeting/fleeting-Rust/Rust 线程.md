---
title: Rust线程
date: 2021-10-19 20:28
modify: 星期二 19日 十月 2021 20:28:17
author: edony.zpc
tags: 001-computer-technology
---

# Rust 线程
编程语言有一些不同的方法来实现线程。很多操作系统提供了创建新线程的 API。这种由编程语言调用操作系统 API 创建线程的模型有时被称为 _1:1_，一个 OS 线程对应一个语言线程。

很多编程语言提供了自己特殊的线程实现。编程语言提供的线程被称为 **绿色**（_green_）线程，使用绿色线程的语言会在不同数量的 OS 线程的上下文中执行它们。为此，绿色线程模式被称为 _M:N_ 模型：`M` 个绿色线程对应 `N` 个 OS 线程，这里 `M` 和 `N` 不必相同。

每一个模型都有其优势和取舍。对于 Rust 来说最重要的取舍是运行时支持。**运行时**（_Runtime_）是一个令人迷惑的概念，其在不同上下文中可能有不同的含义。

在当前上下文中，**运行时** 代表二进制文件中包含的由语言自身提供的代码。这些代码根据语言的不同可大可小，不过任何非汇编语言都会有一定数量的运行时代码。为此，通常人们说一个语言 “没有运行时”，一般意味着 “小运行时”。更小的运行时拥有更少的功能不过其优势在于更小的二进制输出，这使其易于在更多上下文中与其他语言相结合。虽然很多语言觉得增加运行时来换取更多功能没有什么问题，但是 Rust 需要做到几乎没有运行时，同时为了保持高性能必须能够调用 C 语言，这点也是不能妥协的。

绿色线程的 M:N 模型需要更大的语言运行时来管理这些线程。因此，Rust 标准库只提供了 1:1 线程模型实现。由于 Rust 是较为底层的语言，如果你愿意牺牲性能来换取抽象，以获得对线程运行更精细的控制及更低的上下文切换成本，你可以使用实现了 M:N 线程模型的 crate。

## 创建线程
```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }
}

// 注意这个函数编写的方式，当主线程结束时，新线程也会结束，而不管其是否执行完毕。
//
// hi number 1 from the main thread!
// hi number 1 from the spawned thread!
// hi number 2 from the main thread!
// hi number 2 from the spawned thread!
// hi number 3 from the main thread!
// hi number 3 from the spawned thread!
// hi number 4 from the main thread!
// hi number 4 from the spawned thread!
// hi number 5 from the spawned thread!

```

## 线程管理
### join 线程
通过将 `thread::spawn` 的返回值储存在变量中来修复新建线程部分没有执行或者完全没有执行的问题。`thread::spawn` 的返回值类型是 `JoinHandle`。`JoinHandle` 是一个拥有所有权的值，当对其调用 `join` 方法时，它会等待其线程结束。
```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap();
}

// hi number 1 from the main thread!
// hi number 2 from the main thread!
// hi number 1 from the spawned thread!
// hi number 3 from the main thread!
// hi number 2 from the spawned thread!
// hi number 4 from the main thread!
// hi number 3 from the spawned thread!
// hi number 4 from the spawned thread!
// hi number 5 from the spawned thread!
// hi number 6 from the spawned thread!
// hi number 7 from the spawned thread!
// hi number 8 from the spawned thread!
// hi number 9 from the spawned thread!

```

`join` 放置于何处这样的小细节，会影响线程是否同时运行。
```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    handle.join().unwrap();

    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }
}

// hi number 1 from the spawned thread!
// hi number 2 from the spawned thread!
// hi number 3 from the spawned thread!
// hi number 4 from the spawned thread!
// hi number 5 from the spawned thread!
// hi number 6 from the spawned thread!
// hi number 7 from the spawned thread!
// hi number 8 from the spawned thread!
// hi number 9 from the spawned thread!
// hi number 1 from the main thread!
// hi number 2 from the main thread!
// hi number 3 from the main thread!
// hi number 4 from the main thread!
```

### 访问线程数据
`move` 关键字强制闭包获取其使用的环境值的所有权。这个技巧在创建新线程将值的所有权从一个线程移动到另一个线程时最为实用。

#### move
如下代码所示，闭包使用了 `v`，所以闭包会捕获 `v` 并使其成为闭包环境的一部分。因为 `thread::spawn` 在一个新线程中运行这个闭包，所以可以在新线程中访问 `v`。Rust 会 **推断** 如何捕获 `v`，因为 `println!` 只需要 `v` 的引用，闭包尝试借用 `v`。然而这有一个问题：Rust 不知道这个新建线程会执行多久，所以无法知晓 `v` 的引用是否一直有效。
```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(|| {
        println!("Here's a vector: {:?}", v);
    });

    handle.join().unwrap();
}

// error[E0373]: closure may outlive the current function, but it borrows `v`,
// which is owned by the current function
//  --> src/main.rs:6:32
//   |
// 6 |     let handle = thread::spawn(|| {
//   |                                ^^ may outlive borrowed value `v`
// 7 |         println!("Here's a vector: {:?}", v);
//   |                                           - `v` is borrowed here
//   |
// help: to force the closure to take ownership of `v` (and any other referenced
// variables), use the `move` keyword
//   |
// 6 |     let handle = thread::spawn(move || {
//   |                                ^^^^^^^

```

增加 `move` 关键字，我们强制闭包获取其使用的值的所有权，而不是任由 Rust 推断它应该借用值：
```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });

    handle.join().unwrap();
}

```

#### drop
**代码段一：**
```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(|| {
        println!("Here's a vector: {:?}", v);
    });

    drop(v); // error

    handle.join().unwrap();
}

// help: to force the closure to take ownership of `v` (and any other referenced
// variables), use the `move` keyword
//   |
// 6 |     let handle = thread::spawn(move || {
//   |                                ^^^^^^^

```

假如这段代码能正常运行的话，则新建线程则可能会立刻被转移到后台并完全没有机会运行。新建线程内部有一个 `v` 的引用，不过主线程立刻就使用 `drop` 丢弃了 `v`。接着当新建线程开始执行，`v` 已不再有效，所以其引用也是无效的。

**代码段二：**
```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];

    let handle = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });

	drop(v); // error

    handle.join().unwrap();
}

// error[E0382]: use of moved value: `v`
//   --> src/main.rs:10:10
//    |
// 6  |     let handle = thread::spawn(move || {
//    |                                ------- value moved (into closure) here
// ...
// 10 |     drop(v); // error
//    |          ^ value used here after move
//    |
//    = note: move occurs because `v` has type `std::vec::Vec<i32>`, which does
//    not implement the `Copy` trait

```

那么如果使用了 `move` 闭包，主线程调用了 `drop` 的代码会发生什么呢？加了 `move` 就搞定了吗？不幸的是，我们会得到一个不同的错误，`drop` 操作由于一个不同的原因而不被允许。如果为闭包增加 `move`，将会把 `v` 移动进闭包的环境中，如此将不能在主线程中对其调用 `drop` 了。

## References
1. [线程](https://kaisery.github.io/trpl-zh-cn/ch16-01-threads.html)