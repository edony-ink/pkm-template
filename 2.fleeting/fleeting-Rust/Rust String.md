---
title: Rust String
date: 2021-09-26 14:47
modify: 星期日 26日 九月 2021 14:48:04
author: edony.zpc
tags: 001-computer-technology
---

# Rust String
## 新建
```rust
// 1
let mut s = String::new();

// 2
// 该方法也可直接用于字符串字面值:
let s = "initial contents".to_string();

// 3
let s = String::from("initial contents");
```
## 写
```rust
let mut s = String::from("foo");
let s2 = "bar";
s.push_str(s2);
println!("s2 is {}", s2); // running ok, for push_str is not take ownership of var s2

let mut s3 = String::from("lo");
s3.push('l');


let s4 = String::from("Hello, ");
let s5 = String::from("world!");
let s6 = s4 + &s5; // 注意 s4 被移动了，不能继续使用


let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");
let s = format!("{}-{}-{}", s1, s2, s3);
```
## 读
```rust
for c in "नमस्ते".chars() {
    println!("{}", c);
}

for b in "नमस्ते".bytes() {
	println!("{}", b);
}
```
## References
1. [字符串](https://kaisery.github.io/trpl-zh-cn/ch08-02-strings.html)