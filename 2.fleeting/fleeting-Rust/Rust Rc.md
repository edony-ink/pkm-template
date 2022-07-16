---
title: Rust Rc
date: 2021-10-19 17:01
modify: 星期二 19日 十月 2021 17:02:01
author: edony.zpc
tags: 001-computer-technology
---

# Rust Rc
为了启用多所有权，Rust 有一个叫做 `Rc<T>` 的类型。其名称为 **引用计数**（_reference counting_）的缩写。引用计数意味着记录一个值引用的数量来知晓这个值是否仍在被使用。如果某个值有零个引用，就代表没有任何有效引用并可以被清理。

`Rc<T>` 用于当我们希望在堆上分配一些内存供程序的多个部分读取，而且无法在编译时确定程序的哪一部分会最后结束使用它的时候。如果确实知道哪部分是最后一个结束使用的话，就可以令其成为数据的所有者，正常的所有权规则就可以在编译时生效。注意 `Rc<T>` 只能用于单线程场景。

## Rc 指针共享数据
如下图所示，创建三个列表，其中两个共享第三个列表。
![[Pasted image 20211019191714.png]]

尝试使用 Box 指针来实现：
```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let a = Cons(5,
        Box::new(Cons(10,
            Box::new(Nil))));
    let b = Cons(3, Box::new(a));
    let c = Cons(4, Box::new(a));
}

// error[E0382]: use of moved value: `a`
//   --> src/main.rs:13:30
//    |
// 12 |     let b = Cons(3, Box::new(a));
//    |                              - value moved here
// 13 |     let c = Cons(4, Box::new(a));
//    |                              ^ value used here after move
//    |
//    = note: move occurs because `a` has type `List`, which does not implement
//    the `Copy` trait
```

`Cons` 成员拥有其储存的数据，所以当创建 `b` 列表时，`a` 被移动进了 `b` 这样 `b` 就拥有了 `a`。接着当再次尝试使用 `a` 创建 `c` 时，这不被允许，因为 `a` 的所有权已经被移动。

尝试使用 `Rc` 指针替代 `Box` 指针实现：
```rust
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
	// 每次调用 `Rc::clone`，`Rc<List>` 中数据的引用计数都会增加，直到有零个引用之前其数据都不会被清理
    let b = Cons(3, Rc::clone(&a));
    let c = Cons(4, Rc::clone(&a));
}

```

我们可以查看一下引用计数：
```rust
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
	// 调用 `Rc::strong_count` 函数获得引用计数
    println!("count after creating a = {}", Rc::strong_count(&a));
    let b = Cons(3, Rc::clone(&a));
    println!("count after creating b = {}", Rc::strong_count(&a));
    {
        let c = Cons(4, Rc::clone(&a));
        println!("count after creating c = {}", Rc::strong_count(&a));
    }
    println!("count after c goes out of scope = {}", Rc::strong_count(&a));
}

// 结果输出：
// count after creating a = 1
// count after creating b = 2
// count after creating c = 3
// count after c goes out of scope = 2

```