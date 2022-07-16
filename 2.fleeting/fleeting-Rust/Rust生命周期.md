---
title: Rust生命周期
date: 2021-09-26 17:54
modify: 星期日 26日 九月 2021 17:54:49
author: edony.zpc
tags: 001-computer-technology
---

# Rust生命周期
> Rust 中的每一个[[Rust 所有权#借用|引用]]都有其 **生命周期**（_lifetime_），也就是引用保持有效的作用域。大部分时候生命周期是隐含并可以推断的，正如大部分时候类型也是可以推断的一样。类似于当因为有多种可能类型的时候必须注明类型，也会出现引用的生命周期以一些不同方式相关联的情况，所以 Rust 需要我们使用泛型生命周期参数来注明他们的关系，这样就能确保运行时实际使用的引用绝对是有效的。

## Dangling Reference
```rust
{
	let r;
	
	{
		let x = 5;
		r = &x;
	}
	
	// Error: dangling reference from borrow inner var
	println!("r: {}", r);
}
```

## 函数中的生命周期
```rust
// Error: x and y have not same lifetime, if-else is not sure use which lifetime
fn longest(x: &str, y: &str) -> &str {
	if x.len() > y.len() {
		x
	} else {
		y
	}
}

// fix
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
	if x.len() > y.len() {
		x
	} else {
		y
	}
}

// 注意：函数返回引用的生命周期应该与传入参数的生命周期中较短那个保持一致
```

## 结构体的生命周期
```rust
// 注意：定义包含引用的结构体需要为结构体定义中的每一个引用添加生命周期注解

struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.')
        .next()
        .expect("Could not find a '.'");
    let i = ImportantExcerpt { part: first_sentence };
}

```

## 生命周期省略
生命周期可以省略的三个条件：
1. 每一个是引用的参数都有它自己的生命周期参数，e.g `fn foo<'a, 'b>(x: &'a i32, y: &'b i32)`
2. 如果只有一个输入生命周期参数，那么它被赋予所有输出生命周期参数，e.g. `fn foo<'a>(x: &'a i32) -> &'a i32`
3. 如果方法有多个输入生命周期参数并且其中一个参数是 `&self` 或 `&mut self`，那么所有输出生命周期参数被赋予 `self` 的生命周期

*样例代码说明：*
```rust
// example 1
fn first_word(s: &str) -> &str {
// rule 1
fn first_word<'a>(s: &'a str) -> &str {
// rule 2
fn first_word<'a>(s: &'a str) -> &'a str {
// rule 3 ignore
// Ok

// example 2
fn longest(x: &str, y: &str) -> &str {
// rule 1
fn longest<'a, 'b>(x: &'a str, y: &'b str) -> &str {
// rule 2 ignore
// rule 3 ignore
// Error
```

## 方法的生命周期
```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
	fn level(&self) -> i32 {
		3
	}

	fn announce_and_return_part(&self, announcement: &str) -> &str {
		println!("Attention please: {}", announcement);
		self.part
	}
	// 忽略生命周期
	// rule 1
	fn announce_and_return_part<'a, 'b>(&'a self, announcement: &'b str) -> &str
	// rule 2 ignore
	// rule 3
	fn announce_and_return_part<'a, 'b>(&'a self, announcement: &'b str) -> 'a str
}
```

## 静态生命周期
```rust
// `'static`，其生命周期**能够**存活于整个程序期间
let s: &'static str = "I have a static lifetime.";
```

## 范型、trait bounds的生命周期
```rust
use std::fmt::Display;

fn longest_with_an_announcement<'a, T>(x: &'a str, y: &'a str, ann: T) -> &'a str
    where T: Display
{
    println!("Announcement! {}", ann);
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

## References
1. [生命周期与引用有效性](https://kaisery.github.io/trpl-zh-cn/ch10-03-lifetime-syntax.html)