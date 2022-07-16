---
title: Rust Box
date: 2021-10-14 17:33
modify: 星期四 14日 十月 2021 17:33:13
author: edony.zpc
tags: 001-computer-technology
---

# Rust Box
## Box 智能指针
```rust
// 智能指针Box<T>将数据存储在堆上
fn main() {
    let b = Box::new(5);
    println!("b = {}", b);
}
```
`Box<T>` 类型是一个智能指针，因为它实现了 `Deref` trait，它允许 `Box<T>` 值被当作引用对待。当 `Box<T>` 值离开作用域时，由于 `Box<T>` 类型 `Drop` trait 的实现，box 所指向的堆数据也会被清除。Box 智能指针多用于如下场景：
- 当有一个在编译时未知大小的类型，而又想要在需要确切大小的上下文中使用这个类型值的时候
- 当有大量数据并希望在确保数据不被拷贝的情况下转移所有权的时候
- 当希望拥有一个值并只关心它的类型是否实现了特定 trait 而不是其具体类型的时候

## Box 创建递归类型
Rust 需要在编译时知道类型占用多少空间。一种无法在编译时知道大小的类型是 **递归类型**（_recursive type_），其值的一部分可以是相同类型的另一个值。这种值的嵌套理论上可以无限的进行下去，所以 Rust 不知道递归类型需要多少空间。不过 box 有一个已知的大小，所以通过在循环类型定义中插入 box，就可以创建递归类型了。_cons list_ 是一个来源于 Lisp 编程语言及其方言的数据结构。在 Lisp 中，`cons` 函数（“construct function" 的缩写）利用两个参数来构造一个新的列表，他们通常是一个单独的值和另一个列表。

cons 函数的概念涉及到更常见的函数式编程术语；“将 _x_ 与 _y_ 连接” 通常意味着构建一个新的容器而将 _x_ 的元素放在新容器的开头，其后则是容器 _y_ 的元素。

cons list 的每一项都包含两个元素：当前项的值和下一项。其最后一项值包含一个叫做 `Nil` 的值且没有下一项。cons list 通过递归调用 `cons` 函数产生。代表递归的终止条件（base case）的规范名称是 `Nil`，它宣布列表的终止。注意这不同于第六章中的 “null” 或 “nil” 的概念，他们代表无效或缺失的值。

```rust
enum List {
	Cons(i32, List),
	Nil,
}

fn main() {
	let list = Cons(1, Cons(2, Cons(3, Nil)));
}


// error[E0072]: recursive type `List` has infinite size
//  --> src/main.rs:1:1
//   |
// 1 | enum List {
//   | ^^^^^^^^^ recursive type has infinite size
// 2 |     Cons(i32, List),
//   |               ----- recursive without indirection
//   |
//   = help: insert indirection (e.g., a `Box`, `Rc`, or `&`) at some point to
//   make `List` representable
// 
```

Rust 编译器因为无法检查 `List` 递归类型的大小所以编译报错，计算过程如下图所示：
![[Pasted image 20211019153206.png]]

为了解决这个问题，需要将未知大小的 `List` 转换成已知大小的变量，`Box<T>` 就是一种方式：
```rust
use crate::List::{Cons, Nil};

enum List {
	Cons(i32, Box<List>),
	Nil,
}

fn main() {
	let list = Cons(1,
		Box::new(Cons(2,
			Box::new(Cons(3,
				Box::new(Cons(Nil)))))));
}

```
因为 `Box<List>` 指针占用的是一个指针数据大小即已知大小，那么 `Cons(i32, Box<List>)` 的大小就是已知的了。

## References
1. 