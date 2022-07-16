---
title: Rust 高级类型
date: 2021-10-22 17:56
modify: 星期五 22日 十月 2021 17:56:06
author: edony.zpc
tags: 001-computer-technology
---

# Rust 高级类型
## 类型别名
```rust
type Kilometers = i32;

let x: i32 = 5;
let y: Kilometers = 5;

println!("x + y = {}", x + y);


//////////////////////////////////////////////////
type Thunk = Box<dyn Fn() + Send + 'static>;

let f: Thunk = Box::new(|| println!("hi"));

fn takes_long_type(f: Thunk) {
    // --snip--
}

fn returns_long_type() -> Thunk {
    // --snip--
    Box::new(|| ())
}


//////////////////////////////////////////////////
type Result<T> = std::result::Result<T, std::io::Error>;
pub trait Write {
    fn write(&mut self, buf: &[u8]) -> Result<usize>;
    fn flush(&mut self) -> Result<()>;

    fn write_all(&mut self, buf: &[u8]) -> Result<()>;
    fn write_fmt(&mut self, fmt: Arguments) -> Result<()>;
}

```

## never type
Rust 有一个叫做 `!` 的特殊类型。在类型理论术语中，它被称为 _empty type_，因为它没有值。我们更倾向于称之为 _never type_。这个名字描述了它的作用：在函数从不返回的时候充当返回值。
```rust
fn bar() -> ! {}
```

### never type: continue
``` rust
let guess = match guess.trim().parse() {
    Ok(_) => 5,
	// error
    Err(_) => "hello",
}


let guess: u32 = match guess.trim().parse() {
    Ok(num) => num,
    Err(_) => continue,
};

```

### never type: panic!
```rust
impl<T> Option<T> {
    pub fn unwrap(self) -> T {
        match self {
            Some(val) => val,
            None => panic!("called `Option::unwrap()` on a `None` value"),
        }
    }
}

```

### never type: loop
```rust
print!("forever ");

loop {
    print!("and ever ");
}

```

## 动态大小类型
`str` 是一个**动态大小类型**（_dynamically sized types_）；直到运行时我们都不知道字符串有多长。因为直到运行时都不能知道其大小，也就意味着不能创建 `str` 类型的变量，也不能获取 `str` 类型的参数。
```rust
// 不正确
let s1: str = "Hello there!";
let s2: str = "How's it going?";
```

另一个动态大小类型：trait。每一个 trait 都是一个可以通过 trait 名称来引用的动态大小类型。我们为了将 trait 用于 trait 对象，必须将他们放入指针之后，比如 `&dyn Trait` 或 `Box<dyn Trait>`（`Rc<dyn Trait>` 也可以）。为了处理 DST，Rust 有一个特定的 trait 来决定一个类型的大小是否在编译时可知：这就是 `Sized` trait。这个 trait 自动为编译器在编译时就知道大小的类型实现。另外，Rust 隐式的为每一个泛型函数增加了 `Sized` bound。也就是说，对于如下泛型函数定义：
```rust
fn generic<T>(t: T) {
    // --snip--
}

fn generic<T: Sized>(t: T) {
    // --snip--
}

// `?Sized` trait bound 与 `Sized` 相对；也就是说，它可以读作 “`T` 可能是也可能不是 `Sized` 的”。这个语法只能用于 `Sized` ，而不能用于其他 trait。
fn generic<T: ?Sized>(t: &T) {
    // --snip--
}
```