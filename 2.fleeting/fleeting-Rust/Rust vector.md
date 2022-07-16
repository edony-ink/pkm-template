---
title: vector
date: 2021-09-26 14:15
modify: 星期日 26日 九月 2021 14:16:03
author: edony.zpc
tags: 001-computer-technology
---

# Rust vector
## 新建
```rust
let v: Vec<i32> = Vec::new();

let v2 = vec![1, 2, 3];
```
## 读
```rust
let v = vec![1, 2, 3, 4, 5];

let third: &i32 = &v[2];
println!("The third element is {}", third);

match v.get(2) {
    Some(third) => println!("The third element is {}", third),
    None => println!("There is no third element."),
}
```
## 写
```rust
let mut v = Vec::new();

v.push(5);
v.push(6);
v.push(7);
v.push(8);

v.pop(); // delete the last element
```
## 遍历
```rust
let v = vec![100, 32, 57];
for i in &v {
    println!("{}", i);
}


let mut v = vec![100, 32, 57];
for i in &mut v {
	// 可变引用，需要解引用才能修改指向的值
    *i += 50;
}
```
## 多类型
```rust
enum SpreadsheetCell {
    Int(i32),
    Float(f64),
    Text(String),
}

let row = vec![
    SpreadsheetCell::Int(3),
    SpreadsheetCell::Text(String::from("blue")),
    SpreadsheetCell::Float(10.12),
];
```
## References
1. [vector](https://kaisery.github.io/trpl-zh-cn/ch08-01-vectors.html)