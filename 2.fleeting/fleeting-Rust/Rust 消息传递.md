---
title: Rust 消息传递
date: 2021-10-19 20:30
modify: 星期三 20日 十月 2021 10:53:53
author: edony.zpc
tags: 001-computer-technology
---

# Rust 消息传递
一个日益流行的确保安全并发的方式是 **消息传递**（_message passing_），这里线程或 actor 通过发送包含数据的消息来相互沟通。这个思想来源于 [Go 编程语言文档中](http://golang.org/doc/effective_go.html) 的口号：“不要通过共享内存来通讯；而是通过通讯来共享内存。”（“Do not communicate by sharing memory; instead, share memory by communicating.”）Rust 中一个实现消息传递并发的主要工具是 **通道**（_channel_），Rust 标准库提供了其实现的编程概念。

## 创建 channel
`mpsc::channel` 函数创建一个新的通道；`mpsc` 是 **多个生产者，单个消费者**（_multiple producer, single consumer_）的缩写。简而言之，Rust 标准库实现通道的方式意味着一个通道可以有多个产生值的 **发送**（_sending_）端，但只能有一个消费这些值的 **接收**（_receiving_）端。`mpsc::channel` 函数返回一个元组：第一个元素是发送端，而第二个元素是接收端。由于历史原因，`tx` 和 `rx` 通常作为 **发送者**（_transmitter_）和 **接收者**（_receiver_）的缩写，所以这就是我们将用来绑定这两端变量的名字。这里使用了一个 `let` 语句和模式来解构了此元组；
```rust
use std::thread;
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap();
    });
	
	let received = rx.recv().unwrap();
	println!("Got: {}", received);
}

```

## channel 方法
### send
通道的发送端有一个 `send` 方法用来获取需要放入通道的值。`send` 方法返回一个 `Result<T, E>` 类型，所以如果接收端已经被丢弃了，将没有发送值的目标，所以发送操作会返回错误。

### recive
通道的接收端有两个有用的方法：`recv` 和 `try_recv`。这里，我们使用了 `recv`，它是 _receive_ 的缩写。这个方法会阻塞主线程执行直到从通道中接收一个值。一旦发送了一个值，`recv` 会在一个 `Result<T, E>` 中返回它。当通道发送端关闭，`recv` 会返回一个错误表明不会再有新的值到来了。

`try_recv` 不会阻塞，相反它立刻返回一个 `Result<T, E>`：`Ok` 值包含可用的信息，而 `Err` 值代表此时没有任何消息。如果线程在等待消息过程中还有其他工作时使用 `try_recv` 很有用：可以编写一个循环来频繁调用 `try_recv`，在有可用消息时进行处理，其余时候则处理一会其他工作直到再次检查。

## 通道与所有权
所有权规则在消息传递中扮演了重要角色，其有助于我们编写安全的并发代码。防止并发编程中的错误是在 Rust 程序中考虑所有权的一大优势。现在让我们做一个试验来看看通道与所有权如何一同协作以避免产生问题：我们将尝试在新建线程中的通道中发送完 `val` 值 **之后** 再使用它。`send` 函数获取其参数的所有权并移动这个值归接收者所有。这可以防止在发送后再次意外地使用这个值；所有权系统检查一切是否合乎规则。
```rust
use std::thread;
use std::sync::mpsc;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let val = String::from("hi");
        tx.send(val).unwrap();
        println!("val is {}", val);
    });

    let received = rx.recv().unwrap();
    println!("Got: {}", received);
}

// error[E0382]: use of moved value: `val`
//   --> src/main.rs:10:31
//    |
// 9  |         tx.send(val).unwrap();
//    |                 --- value moved here
// 10 |         println!("val is {}", val);
//    |                               ^^^ value used here after move
//    |
//    = note: move occurs because `val` has type `std::string::String`, which does
// not implement the `Copy` trait

```

## 发送多个值
```rust
use std::thread;
use std::sync::mpsc;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread"),
        ];

        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

	// 在主线程中，不再显式调用 `recv` 函数：而是将 `rx` 当作一个迭代器。对于每一个接收到的值，我们将其打印出来。当通道被关闭时，迭代器也将结束。
    for received in rx {
        println!("Got: {}", received);
    }
}

```

## 多个发送着
```rust
use std::thread;
use std::sync::mpsc;
use std::time::Duration;

fn main() {
// --snip--

let (tx, rx) = mpsc::channel();

let tx1 = tx.clone();
thread::spawn(move || {
    let vals = vec![
        String::from("hi"),
        String::from("from"),
        String::from("the"),
        String::from("thread"),
    ];

    for val in vals {
        tx1.send(val).unwrap();
        thread::sleep(Duration::from_secs(1));
    }
});

thread::spawn(move || {
    let vals = vec![
        String::from("more"),
        String::from("messages"),
        String::from("for"),
        String::from("you"),
    ];

    for val in vals {
        tx.send(val).unwrap();
        thread::sleep(Duration::from_secs(1));
    }
});

for received in rx {
    println!("Got: {}", received);
}

// --snip--
}

```
## References
1. 