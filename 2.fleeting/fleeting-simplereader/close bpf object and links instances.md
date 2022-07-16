---
title: close bpf object and links instances
date: 2022-02-23 16:25:21
modify: 2022-02-23 16:25:21
author: edony.zpc
tags: 003-readings
aliases: ebpf obj, ebpf links
summary: 
---

![](https://www.gravatar.com/avatar/f2c009cb225b8ecee8de486630c37225?s=64&d=identicon&r=PG)

Mark

So, I was studying `samples/bpf/*` examples and have found the following pattern in recent code using `libbpf`:

```
struct bpf_link *links[PROGS_NUM] = { NULL, };
struct bpf_program *prog;
struct bpf_object *obj;
int i = 0;

obj = bpf_object__open_file(filename, NULL);
bpf_object__load(obj);
bpf_object__for_each_program(prog, obj) {
   links[i] = bpf_program__attach(prog);
   i++;
}
```

Now, after the programs have been attached, is it fine to close `bpf` object instance, e.g. `bpf_object__close(obj)` or the `obj` and `links` must exist and be accessible as long as programs are loaded in kernel?

![](https://i.stack.imgur.com/078Ob.jpg?s=64&g=1)

Qeole

I have not run specific tests to answer your question, but based on my understanding: “it depends”, in particular on program types. You can likely close the `obj`, but if you also close the `links`, then tracing eBPF programs may be detached and unloaded when your user space loader terminates.

### eBPF Program Lifetime

Once loaded, an eBPF program remains in the kernel as long as its reference counter remains strictly positives. There are a number of “handles” that can hold references to the program:

*   Attaching a program to a hook (such as a TC filter or a kernel probe) increments the counter.
*   A file descriptor that was returned from the kernel either when loading the program, or when requesting a file descriptor to a loaded program, also holds a reference.
*   A pinned path in the eBPF virtual file system does the same thing.
*   Referencing a progam in a `BPF_MAP_TYPE_PROG_ARRAY` map (for tail calls) holds a reference too.

When all those handles are gone - When the program is detached, the user application that loaded it terminates, and it is not pinned to the bpffs, then the program is unloaded.

### eBPF Links

So we said that attaching a program increments its reference counter, which means that as long as the program is attached, it remains loaded. For TC filters or XDP programs for example, this makes things easier, since a user application can attach the program and terminates safely - The program remains attached and loaded. For tracing, attaching a probe is usually done by calling `perf_event_open()`, retrieving a file descriptor (distinct from the one we get when loading the eBPF program), and using it to attach with an `ioctl()`. When this file descriptor is closed, the program is detached [Note: this is my basic understanding of attaching probes, maybe I missed something and there might be other solutions]. So when the user application terminates, both file descriptors (from load and attach) are closed and the program is at the same time detached and unloaded. Pinning the program prevents unloading, but not detaching (so the program is loaded in the kernel but never run).

As a workaround, eBPF links were introduced to provide a better user experience for attaching program, making it easier to keep them attached, and more consistent to manage attachment/detachment. The `struct bpf_link` references the the file descriptor obtained when attaching the program. The link can be pinned to remain persistent when the user application terminates, thus ensuring the probe remains active.

### `obj` and `links`

In your case, what will happen if you close `obj` and `links`?

`obj` is a (pointer to a) `struct bpf_object` whose internals are kept hidden from the user by libbpf. It was built from an object file, and updated when loading the eBPF program contained in that object file. It contains pointers to `struct bpf_program` object with `instances` and at last `fds`, the file descriptors obtained when loading the program. If we close them (through `bpf_object__close()`, calling `bpf_object__unload()``, and in turn` bpf_program__unload()`), those handles for keeping the program are gone. This is not an issue, as long as other references are kept elsewhere - for example, if the program is attached. So I _think_ that` obj` should be safe to close.

If we also close `links`, we also lose the possibility to pin the link. The process still holds the file descriptor from `perf_event_open()`, but it will close it on exit. If the eBPF program was a tracing program, it will be at once detached and unloaded. If it was a networking program, it should remain attached.

So it all depends on your program types and of whether you want your program to keep running. For the tracing and monitoring use cases, pinned eBPF links allow you to keep probing even when the user space loader application exits. So it may be worth double-checking that you don't need those `links` anymore before deleting them :).