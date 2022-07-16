---
title: Rust HashMap
date: 2021-09-26 15:12
modify: 星期日 26日 九月 2021 15:12:19
author: edony.zpc
tags: 001-computer-technology
---

# Rust HashMap
## 新建
```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

let teams = vec![String::from("Blue"), String::from("Yellow")];
let initial_scores = vec![10, 50];
let scores: HashMap<_, _> = teams.iter().zip(initial_scores.iter()).collect();
```
## 读
```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Yellow"), 50);

let team_name = String::from("Blue");
let score = scores.get(&team_name);

for (key, value) in &scores {
	println!("{}: {}", key, value);
}
```
## 写
```rust
let mut scores = HashMap::new();
scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Blue"), 20);	// 更新

scores.entry(String::from("Yellow")).or_insert(50);	// 插入
scores.entry(String::from("Blue")).or_insert(50);	// 不插入
println!("{:?}", scores);
// print result
// {"Yellow": 50, "Blue": 20}
```
## References
1. [哈希map](https://kaisery.github.io/trpl-zh-cn/ch08-03-hash-maps.html)