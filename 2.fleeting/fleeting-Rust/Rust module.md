---
title: Rust module
date: 2021-09-26 12:31
modify: 星期日 26日 九月 2021 14:01:03
author: edony.zpc
tags: 001-computer-technology
---


# Rust module
## Rust内部模块
_**模块**_ 让我们可以将一个 crate 中的代码进行分组，以提高可读性与重用性。模块还可以控制 _**私有性**_，即可以被外部代码使用的（_public_），还是作为一个内部实现的内容，不能被外部代码使用（_private_）。
```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // Absolute path
    crate::front_of_house::hosting::add_to_waitlist();

    // Relative path
    front_of_house::hosting::add_to_waitlist();
}

// super引用
fn serve_order() {}

mod back_of_house {
    fn fix_incorrect_order() {
        cook_order();
        super::serve_order();
    }

    fn cook_order() {}
}

// use引用
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting::add_to_waitlist;

pub fn eat_at_restaurant() {
    add_to_waitlist();
    add_to_waitlist();
    add_to_waitlist();
}

// 别名引用
use std::fmt::Result;
use std::io::Result as IoResult;

fn function1() -> Result {
    // --snip--
    Ok(())
}

fn function2() -> IoResult<()> {
    // --snip--
    Ok(())
}

// pub use
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
	// 如果不采用pub use，外部调用eat_at_restaurant的时候会无法使用hosting::路径
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}

// 嵌套减少use
use std::{cmp::Ordering, io};
use std::io::{self, Write};

// 通配符use
use std::collections::*;
```

## Rust外部模块
在`Cargo.toml`中加入如下依赖配置：
```toml
[dependencies]
rand = "0.5.5"
```
这个配置告诉Cargo需要从[crates.io](https://crates.io/)下载`rand`和它的依赖项，在项目中使用这个模块

## Rust模块文件划分
### 1.声明模块
在Crate根文件中声明模块，
```rust
// 模块声明目录：src/lib.rs
mod front_of_house;
```

### 2.声明子模块
```rust
// 模块定义目录：src/front_of_house.rs
pub mod hosting; // 子模块
```

### 3.模块实现
```rust
// 子模块目录：src/front_of_house/hosting.rs etc.
pub fn add_to_waitlist() {}
```

## References
1. [将模块分割进不同文件](https://kaisery.github.io/trpl-zh-cn/ch07-05-separating-modules-into-different-files.html)