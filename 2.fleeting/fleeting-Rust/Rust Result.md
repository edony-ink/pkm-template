---
title: Rust Result
date: 2021-09-26 15:41
modify: 星期日 26日 九月 2021 15:41:24
author: edony.zpc
tags: 001-computer-technology
---

# Rust Result
## Result枚举
```rust
enum Result<T, E> {
	Ok(T),
	Err(E),
}

// 样例代码
use std::fs::File;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => {
            panic!("Problem opening the file: {:?}", error)
        },
    };
}
```

## 错误匹配
```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("Problem creating the file: {:?}", e),
            },
            other_error => panic!("Problem opening the file: {:?}", other_error),
        },
    };
}

```

## unwrap_or_else
```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt").unwrap_or_else(|error| {
        if error.kind() == ErrorKind::NotFound {
            File::create("hello.txt").unwrap_or_else(|error| {
                panic!("Problem creating the file: {:?}", error);
            })
        } else {
            panic!("Problem opening the file: {:?}", error);
        }
    });
}
```

## Result简写
```rust
use std::fs::File;

fn main() {
	// 说明：Result值如果是成员Ok则unwrap返回Ok中的值，如果是成员Err则unwrap会调用panic!
    let f = File::open("hello.txt").unwrap();
	
	// 说明：expect和unwrap逻辑一样，只不过允许我们使用自己的错误信息
	let f = File::open("hello.txt").expect("Failed to open hello.txt");
}
```

## 传播错误
```rust
use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
```

## ?运算符
```rust
use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```
`File::open` 调用结尾的 `?` 将会把 `Ok` 中的值返回给变量 `f`。如果出现了错误，`?` 运算符会提早返回整个函数并将一些 `Err` 值传播给调用者。同理也适用于 `read_to_string` 调用结尾的 `?`。
## References
1. [Result 与可恢复的错误](https://kaisery.github.io/trpl-zh-cn/ch09-02-recoverable-errors-with-result.html)