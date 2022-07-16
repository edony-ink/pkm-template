---
title: Rust Drop trait
date: 2021-10-19 16:35
modify: 星期二 19日 十月 2021 16:35:13
author: edony.zpc
tags: 001-computer-technology
---

# Rust Drop trait
`Drop`其允许我们在值要离开作用域时执行一些代码。可以为任何类型提供 `Drop` trait 的实现，同时所指定的代码被用于释放类似于文件或网络连接的资源。我们在智能指针上下文中讨论 `Drop` 是因为其功能几乎总是用于实现智能指针。

## drop 方法
`Drop` trait 要求实现一个叫做 `drop` 的方法，它获取一个 `self` 的可变引用。
```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer { data: String::from("my stuff") };
    let d = CustomSmartPointer { data: String::from("other stuff") };
    println!("CustomSmartPointers created.");
}

```

## drop 方法调用
```rust
fn main() {
    let c = CustomSmartPointer { data: String::from("some data") };
    println!("CustomSmartPointer created.");
    c.drop();
    println!("CustomSmartPointer dropped before the end of main.");
}

// error[E0040]: explicit use of destructor method
//   --> src/main.rs:14:7
//    |
// 14 |     c.drop();
//    |       ^^^^ explicit destructor calls not allowed
// 
```
显示的调用 Drop trait 中的方法会导致 double free 的问题，为了能够提前做强制丢弃 Rust 提供了一个方法：`std::mem::drop`，`std::mem::drop` 函数不同于 `Drop` trait 中的 `drop` 方法，它可以通过传递希望提早强制丢弃的值作为参数，`std::mem::drop` 位于 prelude。

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer { data: String::from("some data") };
    println!("CustomSmartPointer created.");
    drop(c);
    println!("CustomSmartPointer dropped before the end of main.");
}

```
## References
1. 