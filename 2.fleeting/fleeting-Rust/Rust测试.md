---
title: Rust测试
date: 2021-09-27 15:05
modify: 星期一 27日 九月 2021 15:05:12
author: edony.zpc
tags: 001-computer-technology
---

# Rust测试
## Rust测试编写
```rust
// #[cfg(test)]注解标明test属性
#[cfg(test)]
mod tests {
	// #[test]属性标明这是测试函数
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}

// 运行测试
// cargo test

// 测试宏
assert!
assert_eq!
assert_ne!
panic!

// should_panic属性
fn main() {}
pub struct Guess {
    value: i32,
}

// --snip--

impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 {
            panic!("Guess value must be greater than or equal to 1, got {}.",
                   value);
        } else if value > 100 {
            panic!("Guess value must be less than or equal to 100, got {}.",
                   value);
        }

        Guess {
            value
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic(expected = "Guess value must be less than or equal to 100")]
    fn greater_than_100() {
        Guess::new(200);
    }
}

```

## Rust测试运行
主要是`cargo test`命令和参数一些运用，参考[运行测试](https://kaisery.github.io/trpl-zh-cn/ch11-02-running-tests.html)

## Rust测试模块
### 单元测试
> 规范是在每个文件中创建包含测试函数的 `tests` 模块，并使用 `cfg(test)` 标注模块。

测试模块的 `#[cfg(test)]` 注解告诉 Rust 只在执行 `cargo test` 时才编译和运行测试代码，而在运行 `cargo build` 时不这么做。这在只希望构建库的时候可以节省编译时间，并且因为它们并没有包含测试，所以能减少编译产生的文件的大小。与之对应的集成测试因为位于另一个文件夹，所以它们并不需要 `#[cfg(test)]` 注解。然而单元测试位于与源码相同的文件中，所以你需要使用 `#[cfg(test)]` 来指定他们不应该被包含进编译结果中。


### 集成测试
> 在 Rust 中，集成测试对于你需要测试的库来说完全是外部的。同其他使用库的代码一样使用库文件，也就是说它们只能调用一部分库中的公有 API 。集成测试的目的是测试库的多个部分能否一起正常工作。

在项目根目录创建一个 _tests_ 目录，与 _src_ 同级，接着可以随意在这个目录中创建任意多的测试文件，Cargo 会将每一个文件当作单独的 crate 来编译。

#### 集成测试子模块
集成测试复杂之后，代码会变多，为了更好的管理集成测试代码，我需要需要进行模块化管理，以通用模块 `common` 为例：
1. 在 tests 目录中创建 common.rs 文件作为通用模块
2. 为了避免 Cargo 将 common.rs 看作测试 crate，做这样的改动：
	- 创建目录 tests/common/
	- 创建文件 tests/common/mod.rs
	- 将 common.rs 定义的通用模块函数移入到 mod.rs中


#### 二进制crate集成测试
如果项目是二进制 crate 并且只包含 _src/main.rs_ 而没有 _src/lib.rs_，这样就不可能在 _tests_ 目录创建集成测试并使用 `extern crate` 导入 _src/main.rs_ 中定义的函数。只有库 crate 才会向其他 crate 暴露了可供调用和使用的函数；二进制 crate 只意在单独运行。

为什么 Rust 二进制项目的结构明确采用 _src/main.rs_ 调用 _src/lib.rs_ 中的逻辑的方式？因为通过这种结构，集成测试 **就可以** 通过 `extern crate` 测试库 crate 中的主要功能了，而如果这些重要的功能没有问题的话，_src/main.rs_ 中的少量代码也就会正常工作且不需要测试。

## References
1. [测试的组织结构](https://kaisery.github.io/trpl-zh-cn/ch11-03-test-organization.html)