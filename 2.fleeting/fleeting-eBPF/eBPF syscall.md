---
title: eBPF syscall
date: 2021-09-28 17:12
modify: 星期二 28日 九月 2021 17:12:51
author: edony.zpc
tags: 001-computer-technology
---

# eBPF syscall
```c
#include <linux/bpf.h>

int bpf(int cmd, union bpf_attr *attr, unsigned int size);
```

### bpf cmd参数
**BPF_MAP_CREATE**
              Create a map and return a file descriptor that refers to
              the map.  The close-on-exec file descriptor flag (see
              [fcntl(2)](https://man7.org/linux/man-pages/man2/fcntl.2.html)) is automatically enabled for the new file
              descriptor.
**BPF_MAP_LOOKUP_ELEM**
              Look up an element by key in a specified map and return
              its value.

**BPF_MAP_UPDATE_ELEM**
              Create or update an element (key/value pair) in a
              specified map.

**BPF_MAP_DELETE_ELEM**
              Look up and delete an element by key in a specified map.

**BPF_MAP_GET_NEXT_KEY**
              Look up an element by key in a specified map and return
              the key of the next element.

**BPF_PROG_LOAD**
              Verify and load an eBPF program, returning a new file
              descriptor associated with the program.  The close-on-exec
              file descriptor flag (see [fcntl(2)](https://man7.org/linux/man-pages/man2/fcntl.2.html)) is automatically
              enabled for the new file descriptor.
## References
1. [bpf(2) - Linux manual page](https://man7.org/linux/man-pages/man2/bpf.2.html)