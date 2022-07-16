---
title: Rust 模式匹配失败
date: 2021-10-21 20:35
modify: 星期四 21日 十月 2021 20:35:55
author: edony.zpc
tags: 001-computer-technology
---

# Rust 模式匹配失败
模式有两种形式：refutable（可反驳的）和 irrefutable（不可反驳的）。能匹配任何传递的可能值的模式被称为是 **不可反驳的**（_irrefutable_）。一个例子就是 `let x = 5;` 语句中的 `x`，因为 `x` 可以匹配任何值所以不可能会失败。对某些可能的值进行匹配会失败的模式被称为是 **可反驳的**（_refutable_）。一个这样的例子便是 `if let Some(x) = a_value` 表达式中的 `Some(x)`；如果变量 `a_value` 中的值是 `None` 而不是 `Some`，那么 `Some(x)` 模式不能匹配。

- 函数参数、 `let` 语句和 `for` 循环只能接受不可反驳的模式，因为通过不匹配的值程序无法进行有意义的工作。
- `if let` 和 `while let` 表达式被限制为只能接受可反驳的模式，因为根据定义他们意在处理可能的失败：条件表达式的功能就是根据成功或失败执行不同的操作。
- `match`匹配分支必须使用可反驳模式，除了最后一个分支需要使用能匹配任何剩余值的不可反驳模式。Rust允许我们在只有一个匹配分支的`match`中使用不可反驳模式，不过这么做不是特别有用，并可以被更简单的 `let` 语句替代。

通常我们无需担心可反驳和不可反驳模式的区别，不过确实需要熟悉可反驳性的概念，这样当在错误信息中看到时就知道如何应对。遇到这些情况，根据代码行为的意图，需要修改模式或者使用模式的结构。

```rust
let Some(x) = some_option_value;
// error[E0005]: refutable pattern in local binding: `None` not covered
//  -->
//   |
// 3 | let Some(x) = some_option_value;
//   |     ^^^^^^^ pattern `None` not covered


// if let 和一个带有可反驳模式的代码块来代替let
let some_option_value: Option<i32> = None;
if let Some(x) = some_option_value {
    println!("{}", x);
}


if let x = 5 {
    println!("{}", x);
};
// warning: irrefutable if-let pattern
//  --> <anon>:2:5
//   |
// 2 | /     if let x = 5 {
// 3 | |     println!("{}", x);
// 4 | | };
//   | |_^
//   |
//   = note: #[warn(irrefutable_let_patterns)] on by default
```
