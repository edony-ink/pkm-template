---
title: Rust Deref trait
date: 2021-10-19 15:54
modify: 星期二 19日 十月 2021 15:59:20
author: edony.zpc
tags: 001-computer-technology
---

# Rust Deref trait
实现 `Deref` trait 允许我们重载 **解引用运算符**（_dereference operator_）`*`（与乘法运算符或通配符相区别）。通过这种方式实现 `Deref` trait 的智能指针可以被当作常规引用来对待，可以编写操作引用的代码并用于智能指针。

## 解引用运算符
```rust
fn main() {
	let x = 5;
	let y = &x;
	
	assert_eq!(5, x);
	assert_eq!(5, y);
}

// error[E0277]: can't compare `{integer}` with `&{integer}`
//  --> src/main.rs:6:5
//   |
// 6 |     assert_eq!(5, y);
//   |     ^^^^^^^^^^^^^^^^^ no implementation for `{integer} == &{integer}`
//   |
//   = help: the trait `std::cmp::PartialEq<&{integer}>` is not implemented for
//   `{integer}`
// 
```
不允许比较数字的引用与数字，因为它们是不同的类型。必须使用解引用运算符追踪引用所指向的值。

## 自定义智能指针
```rust
struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

impl<T> Deref for MyBox<T> {
	// `type Target = T;` 语法定义了用于此 trait 的关联类型。
	type Target = T;
	
	fn deref(&self) -> &T {
		&self.0
	}
}
```

## Deref 强制转换
```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x: T) -> MyBox<T> {
        MyBox(x)
    }
}

impl<T> Deref for MyBox<T> {
    type Target = T;

    fn deref(&self) -> &T {
        &self.0
    }
}

fn hello(name: &str) {
    println!("Hello, {}!", name);
}

fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&m);
	
	// 如果 MyBox 没有实现 Deref，那么我们需要这么写
	hello(&(*m)[..]);
}

```
这里使用 `&m` 调用 `hello` 函数，其为 `MyBox<String>` 值的引用。因为示例 15-10 中在 `MyBox<T>` 上实现了 `Deref` trait，Rust 可以通过 `deref` 调用将 `&MyBox<String>` 变为 `&String`。标准库中提供了 `String` 上的 `Deref` 实现，其会返回字符串 slice，这可以在 `Deref` 的 API 文档中看到。Rust 再次调用 `deref` 将 `&String` 变为 `&str`，这就符合 `hello` 函数的定义了。

## Deref 与可变性
类似于如何使用 `Deref` trait 重载不可变引用的 `*` 运算符，Rust 提供了 `DerefMut` trait 用于重载可变引用的 `*` 运算符。

Rust 在发现类型和 trait 实现满足三种情况时会进行 Deref 强制转换：

-   当 `T: Deref<Target=U>` 时从 `&T` 到 `&U`。
-   当 `T: DerefMut<Target=U>` 时从 `&mut T` 到 `&mut U`。
-   当 `T: Deref<Target=U>` 时从 `&mut T` 到 `&U`。

头两个情况除了可变性之外是相同的：第一种情况表明如果有一个 `&T`，而 `T` 实现了返回 `U` 类型的 `Deref`，则可以直接得到 `&U`。第二种情况表明对于可变引用也有着相同的行为。

第三个情况有些微妙：Rust 也会将可变引用强转为不可变引用。但是反之是 **不可能** 的。

## References
1. 