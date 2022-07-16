---
title: Option枚举
date: 2021-09-24 19:34
modify: 星期五 24日 九月 2021 19:46:30
author: edony.zpc
tags: 001-computer-technology
---

# Option枚举
## Rust空值
> 空值是一个因为某种原因目前无效或缺失的值

Rust 并没有空值，不过它确实拥有一个可以编码存在或不存在概念的枚举，这个枚举是 `Option<T>`。

## `Option<T>`定义
```rust
enum Option<T> {
    Some(T),
    None,
}
```

## 使用`Option<T>`
```rust
let some_number = Some(5);
let some_string = Some("a string");
let absent_number: Option<i32> = None;
```
