---
title: LSM 框架
date: 2021-09-28 19:02
modify: 星期二 28日 九月 2021 19:02:26
author: edony.zpc
tags: 001-computer-technology
---

# LSM 框架
## 1. 背景
2001年之前就有很多安全访问控制模型和框架已经被研究和开发出来，用以增强Linux系统的安全性，例如SELinux，DTE，LIDS等等。这些模型和框架大多以各种不同的内核补丁的形式提供，但是没有一个能够获得统治性的地位进而成为Linux内核标准，使用这些系统需要有编译和定制内核的能力，对于没有内核开发经验的普通用户，获得并使用这些系统是有难度的。在2001年的Linux内核峰会上，美国国家安全局（NSA）介绍了他们关于安全增强Linux（SELinux）的工作，当时Linux内核的创始人Linus Torvalds同意Linux内核确实需要一个通用的安全访问控制框架，但他指出最好是通过可加载内核模块的方法，这样可以支持现存的各种不同的安全访问控制系统。因此Linux安全模块（LSM）应运而生。
LSM是在kernel编译的时候通过配置`CONFIG_DEFAULT_SECURITY`进行选择的built-in kernel里面，当系统中有多个LSM的时候可以通过kernel命令行`security=`进行配置。

## 2. LSM框架

Linus Torvalds对Linux安全模块（LSM）提出了三点要求：
* 真正的通用，当使用一个不同的安全模型的时候，只需要加载一个不同的内核模块
* 概念上简单，对Linux内核影响最小，高效
* 能够支持现存的POSIX.1e capabilities逻辑，作为一个可选的安全模块

### 2.1 设计目标
> 1. 以可加载内核模块的形式实现，不会在安全性方面带来明显的损失也不会带来额外的系统开销
> 2. 为了满足大多数现存Linux安全增强系统的需要，采取简化设计的决策减少了对Linux内核的修改和影响

为了满足这些设计目标，Linux安全模块（LSM）采用了通过在内核源代码中放置钩子的方法，来决策是否可以对内核内部对象进行的访问，这些对象有：任务，inode结点，打开的文件等等。LSM访问内核态对象的大致流程如下图所示：

![[LSM_access_object_flow.png]]

### 2.2 LSM工作原理

为了更加容易理解LSM的工作原理，现在以Linux打开文件`int open(const char *pathname, int flags, mode_t mode);`为例来观察kernel中的LSM模块是如何工作。假设用户态进程调用open接口想要打开某个路径下面的文件，那么会有如下的大致流程：
1. 用户态进程调用以文件路径`filepath`为入参调用`open`接口
2. open系统调用在內核态得到调度，`filepath`字符串用来帮助找到kernel file object
3. kernel DAC模块校验文件权限（即用户态进程是否有文件的open权限）
4. kernel LSM框架依次调用所有激活的LSM模块的file\_open相关的勾子函数，只要有一个勾子函数返回错误则中断该系统调用
5. 所有安全检查通过之后，进程打开文件并返回文件描述符给用户态

![[LSM_call_flow.jpeg]]

### 2.3 勾子函数
目前kernel LSM（version 5.4）框架总共包括了[224个勾子点](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/lsm_hooks.h?h=v5.4-rc6#n1823)。简单说明一下比较常见的勾子点：
```
1. Task Hooks
LSM provides a set of task hooks that enable security modules to manage process security information and to control process operations

2. Program Loading Hooks
LSM provides a set of programloading hooks that are called at critical points during the processing of an execve operation."linux_binprm"

3. IPC Hooks
Security modules can manage security information and perform access control for System V IPC using the LSM IPC hooks.
LSM inserts a hook into the existing ipcperms function so that a security module can perform a check for each existing Linux IPC permission check 

4. Filesystem Hooks
For file operations, three sets of hooks were defined:
    1) filesystem hooks
    2) inode hooks
    3) file hooks

5. Network Hooks
Application layer access to networking is mediated using a set of socket hooks. These hooks, which include interposition of all socket system calls, provide coarse mediation coverage of all socket-based protocols.
Since active user sockets have an associated inode structure, a separate security field was not added to the socket structure or to the lower-level sock structure.
As the socket hooks allow general mediation of network traffic in relation to processes, LSM significantly expands the kernel’s network access control framework (which is already handled at the network layer by Netfilter)(LSM对网络的访问控制和Netfilter保持兼容). 
For example, the sock rcv skb hook allows an inbound packet to be mediated in terms of its destination application, prior to being queued at the associated userspace socket.

6. Other Hooks
LSM provides two additional sets of hooks: 
    1) module hooks
    Module hooks can be used to control the kernel operations that create, initialize, and delete kernel modules.

    2) a set of top-level system hooks
    System hooks can be used to control system operations, such as setting the system hostname, accessing I/O ports, and configuring process accounting.
```
内核安全相关的关键对象有：task_struct(任务和进程)、linux_binprm(程序)、super_block(文件系统)、inode(管道、文件或者 socket套接字)、file(打开的文件)、sk_buff(网络缓冲区)、net_device(网络设备)、ker_ipc_perm(Semaphore消息，共享内存段，消息队列)、msg_msg(单个消息)。
![[Pasted image 20220221161028.png]]


## References
1. [LSM基本了解 - CodeAntenna](https://codeantenna.com/a/rKT3XysTRU)