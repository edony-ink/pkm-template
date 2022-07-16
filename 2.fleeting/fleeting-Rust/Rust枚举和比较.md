---
title: Rust枚举和比较
date: 2021-09-24 19:24
modify: 星期五 24日 九月 2021 19:31:41
author: edony.zpc
tags: 001-computer-technology
---

# Rust枚举和比较

```rust
enum Message {
	Quit,
	Move { x: i32, y: i32 },
	Write(String),
	ChangeColor(i32, i32, i32),
}

impl Message {
	fn call(&self) {
		// 在这里定义方法体
	}
}

#![allow(unused)]
fn main() {
	enum IpAddrKind {
	    V4,
	    V6,
	}
	
	struct IpAddr {
	    kind: IpAddrKind,
	    address: String,
	}
	
	let home = IpAddr {
	    kind: IpAddrKind::V4,
	    address: String::from("127.0.0.1"),
	};
	
	let loopback = IpAddr {
	    kind: IpAddrKind::V6,
	    address: String::from("::1"),
	};

	let m = Message::Write(String::from("hello"));
	m.call();
}

```

## References
1. [定义枚举](https://kaisery.github.io/trpl-zh-cn/ch06-01-defining-an-enum.html)