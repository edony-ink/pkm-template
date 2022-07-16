---
title: Rust迭代器
date: 2021-09-27 16:04
modify: 星期一 27日 九月 2021 16:04:51
author: edony.zpc
tags: 001-computer-technology
---

# Rust 迭代器
> **迭代器**（_iterator_）负责遍历序列中的每一项和决定序列何时结束的逻辑。在 Rust 中，迭代器是 **惰性的**（_lazy_），这意味着在调用方法使用迭代器之前它都不会有效果.

```rust
// 下面这段代码其实没有任何意义，仅仅是创建了一个迭代器但是迭代器没有生效
let v1 = vec![1, 2, 3];
let v1_iter = v1.iter();
```

迭代器都实现了一个叫做 `Iterator` 的定义于标准库的 trait。这个 trait 的定义看起来像这样：

```rust
pub trait Iterator {
	// 说明：type Item 和 Self::Item 是 trait 的关联类型
    type Item;
    fn next(&mut self) -> Option<Self::Item>;

    // 此处省略了方法的默认实现
}
```

## 使用迭代器
```rust
let v1 = vec![1, 2, 3];
let v1_iter = v1.iter();

for val in v1_iter {
    println!("Got: {}", val);
}

let mut v1_iter_2 = v1.iter();
assert_eq!(v1_iter_2.next(), Some(&1));
assert_eq!(v1_iter_2.next(), Some(&2));
assert_eq!(v1_iter_2.next(), Some(&3));
assert_eq!(v1_iter_2.next(), None);
```

注意 `v1_iter_2` 需要是可变的：在迭代器上调用 `next` 方法改变了迭代器中用来记录序列位置的状态。换句话说，代码 **消费**（consume）了，或使用了迭代器。每一个 `next` 调用都会从迭代器中消费一个项。使用 `for` 循环时无需使 `v1_iter` 可变因为 `for` 循环会获取 `v1_iter` 的所有权并在后台使 `v1_iter` 可变。

另外需要注意到从 `next` 调用中得到的值是 vector 的不可变引用。`iter` 方法生成一个不可变引用的迭代器。如果我们需要一个获取 `v1` 所有权并返回拥有所有权的迭代器，则可以调用 `into_iter` 而不是 `iter`。类似的，如果我们希望迭代可变引用，则可以调用 `iter_mut` 而不是 `iter`。

## 消费迭代器
迭代器调用 `next` 方法的方法被称为 **消费适配器**（_consuming adaptors_），因为调用他们会消耗迭代器。一个消费适配器的例子是 `sum` 方法。这个方法获取迭代器的所有权并反复调用 `next` 来遍历迭代器，因而会消费迭代器。当其遍历每一个项时，它将每一个项加总到一个总和并在迭代完成时返回总和。
```rust
#[test]
fn iterator_sum() {
    let v1 = vec![1, 2, 3];

    let v1_iter = v1.iter();

    let total: i32 = v1_iter.sum();

    assert_eq!(total, 6);
}
```

## 创建新迭代器
`Iterator` trait 中定义了另一类方法，被称为 **迭代器适配器**（_iterator adaptors_），他们允许我们将当前迭代器变为不同类型的迭代器。可以链式调用多个迭代器适配器。不过因为所有的迭代器都是惰性的，必须调用一个消费适配器方法以便获取迭代器适配器调用的结果。
`map` 方法使用闭包来调用每个元素以生成新的迭代器。 这里的闭包创建了一个新的迭代器，对其中 vector 中的每个元素都被加 1。不过这些代码会产生一个警告：
```rust
let v1: Vec<i32> = vec![1, 2, 3];

v1.iter().map(|x| x + 1);

// warning: unused `std::iter::Map` which must be used: iterator adaptors are lazy
// and do nothing unless consumed
//  --> src/main.rs:4:5
//   |
// 4 |     v1.iter().map(|x| x + 1);
//   |     ^^^^^^^^^^^^^^^^^^^^^^^^^
//   |
//   = note: #[warn(unused_must_use)] on by default

```

代码实际上并没有做任何事；所指定的闭包从未被调用过。警告提醒了我们为什么：迭代器适配器是惰性的，而这里我们需要消费迭代器。为了修复这个警告并消费迭代器获取有用的结果，我们使用 `collect` 方法,这个方法消费迭代器并将结果收集到一个数据结构中：
```rust
let v1: Vec<i32> = vec![1, 2, 3];

let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

assert_eq!(v2, vec![2, 3, 4]);
```

另一个迭代适配器`filter`，`filter` 方法获取一个使用迭代器的每一个项并返回布尔值的闭包。如果闭包返回 `true`，其值将会包含在 `filter` 提供的新迭代器中。如果闭包返回 `false`，其值不会包含在结果迭代器中。，代码示例如下：
```rust
#[derive(PartialEq, Debug)]
struct Shoe {
    size: u32,
    style: String,
}

fn shoes_in_my_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
    shoes.into_iter()
        .filter(|s| s.size == shoe_size)
        .collect()
}

#[test]
fn filters_by_size() {
    let shoes = vec![
        Shoe { size: 10, style: String::from("sneaker") },
        Shoe { size: 13, style: String::from("sandal") },
        Shoe { size: 10, style: String::from("boot") },
    ];

    let in_my_size = shoes_in_my_size(shoes, 10);

    assert_eq!(
        in_my_size,
        vec![
            Shoe { size: 10, style: String::from("sneaker") },
            Shoe { size: 10, style: String::from("boot") },
        ]
    );
}
```

## 自定义迭代器
我们已经展示了可以通过在 vector 上调用 `iter`、`into_iter` 或 `iter_mut` 来创建一个迭代器。也可以用标准库中其他的集合类型创建迭代器，比如哈希 map。另外，可以实现 `Iterator` trait 来创建任何我们希望的迭代器。正如之前提到的，定义中唯一要求提供的方法就是 `next` 方法。一旦定义了它，就可以使用所有其他由 `Iterator` trait 提供的拥有默认实现的方法来创建自定义迭代器了！

示例代码如下所示：
```rust

struct Counter {
    count: u32,
}

impl Counter {
    fn new() -> Counter {
        Counter { count: 0 }
    }
}


struct Counter {
    count: u32,
}

impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        self.count += 1;

        if self.count < 6 {
            Some(self.count)
        } else {
            None
        }
    }
}

#[test]
fn calling_next_directly() {
    let mut counter = Counter::new();

    assert_eq!(counter.next(), Some(1));
    assert_eq!(counter.next(), Some(2));
    assert_eq!(counter.next(), Some(3));
    assert_eq!(counter.next(), Some(4));
    assert_eq!(counter.next(), Some(5));
    assert_eq!(counter.next(), None);
}

#[test]
fn using_other_iterator_trait_methods() {
    let sum: u32 = Counter::new().zip(Counter::new().skip(1))
                                 .map(|(a, b)| a * b)
                                 .filter(|x| x % 3 == 0)
                                 .sum();
    assert_eq!(18, sum);
}
```

## References
1. 