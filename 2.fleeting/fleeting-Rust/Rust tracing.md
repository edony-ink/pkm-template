---
title: Rust tracing
date: 2021-10-28 20:27
modify: 星期四 28日 十月 2021 20:27:38
author: edony.zpc
tags: 001-computer-technology Rust/tracing
---

# Rust tracing
tracing is a framework for instrumenting Rust programs to collect structured, event-based diagnostic information.

In asynchronous systems like Tokio, interpreting traditional log messages can often be quite challenging. Since individual tasks are multiplexed on the same thread, associated events and log lines are intermixed making it difficult to trace the logic flow. tracing expands upon logging-style diagnostics by allowing libraries and applications to record structured events with additional information about temporality and causality — unlike a log message, a span in tracing has a beginning and end time, may be entered and exited by the flow of execution, and may exist within a nested tree of similar spans. In addition, tracing spans are structured, with the ability to record typed data as well as textual messages.

The tracing crate provides the APIs necessary for instrumenting libraries and applications to emit trace data. The core of tracing’s API is composed of spans, events and subscribers. We’ll cover these in turn.

## spans
To record the flow of execution through a program, tracing introduces the concept of spans. Unlike a log line that represents a moment in time, a span represents a period of time with a beginning and an end. When a program begins executing in a context or performing a unit of work, it enters that context’s span, and when it stops executing in that context, it exits the span. The span in which a thread is currently executing is referred to as that thread’s current span.
```rust
use tracing::{span, Level};
let span = span!(Level::TRACE, "my_span");
// `enter` returns a RAII guard which, when dropped, exits the span. this
// indicates that we are in the span for the current lexical scope.
let _enter = span.enter();
// perform some work in the context of `my_span`...
```

## events
An Event represents a moment in time. It signifies something that happened while a trace was being recorded. Events are comparable to the log records emitted by unstructured logging code, but unlike a typical log line, an Event may occur within the context of a span.

In general, events should be used to represent points in time within a span — a request returned with a given status code, n new items were taken from a queue, and so on.
```rust
use tracing::{event, span, Level};

// records an event outside of any span context:
event!(Level::INFO, "something happened");

let span = span!(Level::INFO, "my_span");
let _guard = span.enter();

// records an event within "my_span".
event!(Level::DEBUG, "something happened inside my_span");
```
## subscribers
As Spans and Events occur, they are recorded or aggregated by implementations of the Subscriber trait. Subscribers are notified when an Event takes place and when a Span is entered or exited. These notifications are represented by the following Subscriber trait methods:
- `event`, called when an Event takes place,
- `enter`, called when execution enters a Span,
- `exit`, called when execution exits a Span

In addition, subscribers may implement the enabled function to filter the notifications they receive based on metadata describing each `Span` or `Event`. If a call to `Subscriber::enabled` returns false for a given set of metadata, that `Subscriber` will not be notified about the corresponding `Span` or `Event`. For performance reasons, if no currently active subscribers express interest in a given set of metadata by returning true, then the corresponding Span or Event will never be constructed.

## usage
In order to record trace events, executables have to use a Subscriber implementation compatible with tracing. A Subscriber implements a way of collecting trace data, such as by logging it to standard output.

This library does not contain any Subscriber implementations; these are provided by other crates.

The simplest way to use a subscriber is to call the set_global_default function:
```rust
extern crate tracing;

let my_subscriber = FooSubscriber::new();
tracing::subscriber::set_global_default(my_subscriber)
    .expect("setting tracing default failed");
```
```ad-warning
Warning: In general, libraries should not call set_global_default()! Doing so will cause conflicts when executables that depend on the library try to set the default later.
```
This subscriber will be used as the default in all threads for the remainder of the duration of the program, similar to setting the logger in the log crate.

In addition, the default subscriber can be set through using the with_default function. This follows the tokio pattern of using closures to represent executing code in a context that is exited at the end of the closure. For example:
```rust
let my_subscriber = FooSubscriber::new();
tracing::subscriber::with_default(my_subscriber, || {
    // Any trace events generated in this closure or by functions it calls
    // will be collected by `my_subscriber`.
})
```

This approach allows trace data to be collected by multiple subscribers within different contexts in the program. Note that the override only applies to the currently executing thread; other threads will not see the change from with_default.==Any trace events generated outside the context of a subscriber will not be collected.Once a subscriber has been set, instrumentation points may be added to the executable using the tracing crate’s macros.==

## References
1. [tracing - Rust](https://docs.rs/tracing/0.1.29/tracing/)