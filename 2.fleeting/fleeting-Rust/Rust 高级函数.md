---
title: Rust 高级函数
date: 2021-10-22 18:58
modify: 星期五 22日 十月 2021 18:59:01
author: edony.zpc
tags: 001-computer-technology
---

# Rust 高级函数
## 函数指针
通过函数指针允许我们使用函数作为另一个函数的参数。函数的类型是 `fn` （使用小写的 “f” ）以免与 `Fn` 闭包 trait 相混淆。`fn` 被称为 **函数指针**（_function pointer_）。
```rust
fn add_one(x: i32) -> i32 {
    x + 1
}

fn do_twice(f: fn(i32) -> i32, arg: i32) -> i32 {
    f(arg) + f(arg)
}

fn main() {
    let answer = do_twice(add_one, 5);

    println!("The answer is: {}", answer);
}
```

不同于闭包，`fn` 是一个类型而不是一个 trait，所以直接指定 `fn` 作为参数而不是声明一个带有 `Fn` 作为 trait bound 的泛型参数。

函数指针实现了所有三个闭包 trait（`Fn`、`FnMut` 和 `FnOnce`），所以总是可以在调用期望闭包的函数时传递函数指针作为参数。倾向于编写使用泛型和闭包 trait 的函数，这样它就能接受函数或闭包作为参数。

一个只期望接受 `fn` 而不接受闭包的情况的例子是与不存在闭包的外部代码交互时：C 语言的函数可以接受函数作为参数，但 C 语言没有闭包。

```rust
let list_of_numbers = vec![1, 2, 3];
let list_of_strings: Vec<String> = list_of_numbers
    .iter()
    .map(|i| i.to_string())
    .collect();


let list_of_numbers = vec![1, 2, 3];
let list_of_strings: Vec<String> = list_of_numbers
    .iter()
    .map(ToString::to_string)
    .collect();


// `()` 作为初始化语法，这看起来就像函数调用，同时它们确实被实现为返回由参数构造的实例的函数。它们也被称为实现了闭包 trait 的函数指针
enum Status {
    Value(u32),
    Stop,
}

let list_of_statuses: Vec<Status> =
    (0u32..20)
    .map(Status::Value)
    .collect();
```
## 返回闭包
```rust
fn returns_closure() -> Fn(i32) -> i32 {
    |x| x + 1
}

// error[E0277]: the trait bound `std::ops::Fn(i32) -> i32 + 'static:
// std::marker::Sized` is not satisfied
//  -->
//   |
// 1 | fn returns_closure() -> Fn(i32) -> i32 {
//   |                         ^^^^^^^^^^^^^^ `std::ops::Fn(i32) -> i32 + 'static`
//   does not have a constant size known at compile-time
//   |
//   = help: the trait `std::marker::Sized` is not implemented for
//   `std::ops::Fn(i32) -> i32 + 'static`
//   = note: the return type of a function must have a statically known size


////////////////////////////////////////////////////////////
fn returns_closure() -> Box<dyn Fn(i32) -> i32> {
    Box::new(|x| x + 1)
}
```
