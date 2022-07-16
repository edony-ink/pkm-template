---
title: eBPF helper 函数列表
date: 2021-12-01 16:54
modify: 2021-12-01 17:05:51
author: edony.zpc
tags: 001-computer-technology ebpf/helpers
---


# eBPF helper 函数列表
helper 函数由 libbpf 库提供，定义在 bpf_helpers.h 中。

## bpf_map_lookup_elem
签名： `void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)`

查找eBPF中和一个Key关联的条目。如果找不到条目，返回NULL

## bpf_map_update_elem
签名： `int bpf_map_update_elem(struct bpf_map *map, const void *key, const void *value, u64 flags)`

添加或修改一个Key关联的值。flags可以是以下之一：
- BPF_NOEXIST 键值必须不存在，即执行添加操作。不能和BPF_MAP_TYPE_ARRAY、BPF_MAP_TYPE_PERCPU_ARRAY联用
- BPF_EXIST，键值必须存在，即执行更新操作
- BPF_ANY，更新或修改

## bpf_map_delete_elem
签名： `int bpf_map_delete_elem(struct bpf_map *map, const void *key)`

从eBPF Map中删除条目

## bpf_probe_read
签名： `int bpf_probe_read(void *dst, u32 size, const void *src)`

对于Tracing用途的eBPF程序，可以安全的从src读取size字节存储到dst

## bpf_ktime_get_ns
签名： `u64 bpf_ktime_get_ns(void)`

读取系统从启动到现在的纳秒数，返回ktime

## bpf_trace_printk
签名： `int bpf_trace_printk(const char *fmt, u32 fmt_size, ...)`

类似于printk()的调试工具，从DebugFS打印由fmt所定义的格式化字符串到 /sys/kernel/debug/tracing/trace。最多支持3个额外的u64参数。

每当此函数被调用，它都会打印一行到trace，格式取决于配置 /sys/kernel/debug/tracing/trace_options。默认格式如下：
```shell
# 当前任务的名字
#      当前任务的PID
#            当前CPU序号
#                  每个字符表示一个选项
#                       时间戳
#                                      BPF使用的指令寄存器的Fake值
telnet-470   [001] .N.. 419421.045894: 0x00000001: <formatted msg>
```
可以使用的格式化占位符： %d, %i, %u, %x, %ld, %li, %lu, %lx, %lld, %lli, %llu, %llx, %p, %s。不支持长度、补白等修饰符。

该函数比较缓慢，应该仅用于调试目的。

## bpf_get_prandom_u32
签名： `u32 bpf_get_prandom_u32(void)`

获得一个伪随机数。

## bpf_get_smp_processor_id
签名： `u32 bpf_get_smp_processor_id(void)`

得到SMP处理器ID，需要注意，所有eBPF都在禁止抢占的情况下运行，这意味着在eBPF程序的执行过程中，此ID不会改变。

## bpf_skb_store_bytes
签名： `int bpf_skb_store_bytes(struct sk_buff *skb, u32 offset, const void *from, u32 len, u64 flags)`

存储缓冲区from的len字节到，skb所关联的封包的offset位置。flags是以下位域的组合：

BPF_F_RECOMPUTE_CSUM：自动重新计算修改后的封包的Checksum
BPF_F_INVALIDATE_HASH：重置 skb->hash skb->swhash skb->l4hash为0
调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_skb_load_bytes
签名： `int bpf_skb_load_bytes(const struct sk_buff *skb, u32 offset, void *to, u32 len)`

从skb中的offset位置读取len长的数据，存放到to缓冲区。

从4.7开始，该函数的功能基本被直接封包访问（direct packet access）代替 —— skb->data和 skb->data_end给出了封包数据的位置。如果希望一次性读取大量数据到eBPF，仍然可以使用该函数。

## bpf_l3_csum_replace
签名： `int bpf_l3_csum_replace(struct sk_buff *skb, u32 offset, u64 from, u64 to, u64 size)`

重新计算L3（IP）的Checksum。计算是增量进行的，因此助手函数必须知道被修改的头字段的前值（from）、修改后的值（to），以及被修改字段的字节数（size，2或4）。你亦可将from和size设置为0，并将字段修改前后的差存放到to。offset用于指示封包的IP Checksum的位置

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_l4_csum_replace
签名： `int bpf_l4_csum_replace(struct sk_buff *skb, u32 offset, u64 from, u64 to, u64 flags)`

重新计算L4（TCP/UDP/ICMP）的Checksum。计算是增量进行的，因此助手函数必须知道被修改的头字段的前值（from）、修改后的值（to），以及被修改字段的字节数（存放在flags的低4bit，2或4）。你亦可将from和flags低4bit设置为0，并将字段修改前后的差存放到to。offset用于指示封包的IP Checksum的位置。

flags的高位用于存放以下标记：
- BPF_F_MARK_MANGLED_0，如果Checksum是null，则不去修改它，除非设置了BPF_F_MARK_ENFORCE
- CSUM_MANGLED_0，对于导致Checksum为null的更新操作，设置此标记
- BPF_F_PSEUDO_HDR，提示使用pseudo-header来计算Checksum
调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_tail_call
签名： `int bpf_tail_call(void *ctx, struct bpf_map *prog_array_map, u32 index)`

这是一个特殊的助手函数，用于触发尾调用 —— 跳转到另外一个eBPF程序。新程序将使用一样的栈帧，但是被调用者不能访问调用者在栈上存储的值，以及寄存器。

使用场景包括：
- 突破eBPF程序长度限制
- 在不同条件下进行跳转（到子程序）
- 出于安全原因，可以连续执行的尾调用次数是受限制的。限制定义在内核宏MAX_TAIL_CALL_CNT中，默认32，无法被用户空间访问

当调用发生后，程序尝试跳转到prog_array_map（BPF_MAP_TYPE_PROG_ARRAY类型的Map）的index索引处的eBPF程序，并且将当前ctx传递给它。

如果调用成功，则当前程序被替换掉，不存在函数调用返回。如果调用失败，则不产生任何作用，当前程序继续运行后续指令。失败的原因包括：
- 指定的index不存在eBPF程序
- 当前尾调用链的长度超过限制

## bpf_clone_redirect
签名： `int bpf_clone_redirect(struct sk_buff *skb, u32 ifindex, u64 flags)`

克隆skb关联的封包，并且重定向到由ifindx所指向的网络设备。入站/出站路径都可以用于重定向。标记BPF_F_INGRESS用于确定是重定向到入站（ingress）还是出站（egress）路径，如果该标记存在则入站。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_redirect
签名： `int bpf_redirect(u32 ifindex, u64 flags)`

重定向封包到ifindex所指向的网络设备。类似于bpf_clone_redirect，但是不会进行封包克隆，因而性能较好。缺点是，redirect操作实际上是在eBPF程序返回后的某个代码路径上发生的。

除了XDP之外，入站/出站路径都可以用于重定向。标记BPF_F_INGRESS用于指定是ingress还是egress。当前XDP仅仅支持重定向到egress接口，不支持设置flag

对于XDP，成功返回XDP_REDIRECT，出错返回XDP_ABORTED。对于其它eBPF程序，成功返回TC_ACT_REDIRECT，出错返回TC_ACT_SHOT

## bpf_redirect_map
签名： `int bpf_redirect_map(struct bpf_map *map, u32 key, u64 flags)`

将封包重定向到map的key键指向的endpoint。根据map的类型，它的值可能指向：

网络设备，用于转发封包到其它ports
CPU，用于重定向XDP帧给其它CPU，仅仅支持Native（驱动层支持的） XDP
flags必须置零。

当重定向给网络设备时，该函数比bpf_redirect性能更好。这是由一系列底层实现细节之一决定的，其中之一是该函数会以bulk方式将封包发送给设备。

如果成功返回XDP_REDIRECT，否则返回XDP_ABORTED。

## bpf_sk_redirect_map
签名： `int bpf_sk_redirect_map(struct bpf_map *map, u32 key, u64 flags)`

将封包重定向给map（类型BPF_MAP_TYPE_SOCKMAP）的key所指向的套接字。ingress/egress接口都可以用于重定向。标记BPF_F_INGRESS用于确定是不是ingress。

如果成功返回SK_PASS，否则返回SK_DROP。

## bpf_sock_map_update
签名： `int bpf_sock_map_update(struct bpf_sock_ops *skops, struct bpf_map *map, void *key, u64 flags)`

添加/更新map的条目，skopts作为key的新值。flags是以下其中之一：
- BPF_NOEXIST，仅添加
- BPF_EXIST，仅更新
- BPF_ANY，添加或更新

## bpf_skb_vlan_push
签名： `int bpf_skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci) `

将vlan_proto协议的vlan_tci（VLAN Tag控制信息）Push给skb关联的封包，并且更新Checksum。需要注意ETH_P_8021Q和ETH_P_8021AD的vlan_proto是不一样的，这里使用前者。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_skb_vlan_pop
签名： `int bpf_skb_vlan_pop(struct sk_buff *skb)`

弹出skb关联的封包的VLAN头。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_skb_get_tunnel_key
签名： `int bpf_skb_get_tunnel_key(struct sk_buff *skb, struct bpf_tunnel_key *key, u32 size, u64 flags)`

获取隧道（外层报文）的元数据，skb关联的封包的隧道元数据被填充到key，长度size。标记BPF_F_TUNINFO_IPV6提示隧道是基于IPv6而非IPv4。

bpf_tunnel_key是一个容器结构，它将各种隧道协议的主要参数都存入其中，这样eBPF程序可以方便的根据封装（外层）报文的头来作出各种决定。

对端的IP地址被存放在 key->remote_ipv4 或 key->remote_ipv6

通过 key->tunnel_id可以访问隧道的ID，通常映射到VNI（虚拟网络标识符），调用 bpf_skb_set_tunnel_key()函数需要用到

下面这个示例用在隧道一端的TC Ingress接口，可以过滤掉对端隧道IP不是10.0.0.1的封包：
```c
int ret;
struct bpf_tunnel_key key = {};
 
ret = bpf_skb_get_tunnel_key(skb, &key, sizeof(key), 0);
if (ret < 0)
        return TC_ACT_SHOT;     // drop packet
 
if (key.remote_ipv4 != 0x0a000001)
        return TC_ACT_SHOT;     // drop packet
 
return TC_ACT_OK;               // accept packet
支持VxLAN、Geneve、GRE、IPIP等类型的隧道。

bpf_skb_set_tunnel_key
签名： int bpf_skb_set_tunnel_key(struct sk_buff *skb, struct bpf_tunnel_key *key, u32 size, u64 flags)
```

为skb关联的封包生成隧道元数据。隧道元数据被设置为长度为size的bpf_tunnel_key结构。flags是如下位域的组合：
- BPF_F_TUNINFO_IPV6 指示隧道基于IPv6而非IPv4
- BPF_F_ZERO_CSUM_TX 对于IPv4封包，添加一个标记到隧道元数据，提示应该跳过Checksum计算，将其置零
- BPF_F_DONT_FRAGMENT，添加一个标记到隧道元数据，提示封包不得被分片（fragmented）
- BPF_F_SEQ_NUMBER，添加一个标记到隧道元数据，提示发送封包之前，需要添加sequence number
示例：
```c
struct bpf_tunnel_key key;
// populate key ...
bpf_skb_set_tunnel_key(skb, &key, sizeof(key), 0);
bpf_clone_redirect(skb, vxlan_dev_ifindex, 0);
```

## bpf_skb_get_tunnel_opt
签名： `int bpf_skb_get_tunnel_opt(struct sk_buff *skb, u8 *opt, u32 size)`

从skb关联的封包中获取隧道选项元数据，并且将原始的隧道选项信息存储到大小为size的opt中。

## bpf_skb_set_tunnel_opt
签名： `int bpf_skb_set_tunnel_opt(struct sk_buff *skb, u8 *opt, u32 size)`

将隧道选项元数据设置给skb关联的封包。

## bpf_skb_change_proto
签名： `int bpf_skb_change_proto(struct sk_buff *skb, __be16 proto, u64 flags)`

将skb的协议改为proto。目前仅仅支持将IPv4改为IPv6。助手函数会做好底层工作，例如修改套接字缓冲的大小。eBPF程序需要调用 skb_store_bytes填充必要的新的报文头字段，并调用 bpf_l3_csum_replace、 bpf_l4_csum_replace重新计算Checksum。

该助手函数的主要意义是执行一个NAT64操作。

在内部实现上，封包的GSO（generic segmentation offload）类型标记为dodgy，因而报文头被检查，TCP分段被GSO/GRO引擎重新分段。

flags必须清零，这个参数暂时没有使用。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_csum_diff
签名： `s64 bpf_csum_diff(__be32 *from, u32 from_size, __be32 *to, u32 to_size, __wsum seed)`

计算两个缓冲区from到to的checksum difference。

## bpf_skb_change_type
签名： int bpf_skb_change_type(struct sk_buff *skb, u32 type)

修改封包类型，即设置 skb->pkt_type为type。主要用途是将skb改为PACKET_HOST。type的取值：
- PACKET_HOST 单播给本机的封包
- PACKET_BROADCAST 广播封包
- PACKET_MULTICAST 组播封包
- PACKET_OTHERHOST单播给其它机器的封包

## bpf_skb_change_head
签名： `int bpf_skb_change_head(struct sk_buff *skb, u32 len, u64 flags)`

增长封包的headroom，增长len长度，调整MAC头的偏移量。如果需要，该函数会自动扩展和重新分配内存。

该函数可以用于在L3的skb上，推入一个MAC头，然后将其重定向到L2设备。

flags为保留字段，全部置空。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_skb_under_cgroup
签名： `int bpf_skb_under_cgroup(struct sk_buff *skb, struct bpf_map *map, u32 index)`

检查skb是否是由BPF_MAP_TYPE_CGROUP_ARRAY类型的Map的index位置所指向的CGroup2的descendant。

返回值：

0 ：不是目标Cgroup2的descendant
1：是目标Cgroup2的descendant
负数：出错

## bpf_set_hash_invalid
签名： `void bpf_set_hash_invalid(struct sk_buff *skb)`

无效化 skb->hash。在通过直接封包访问修改报文头之后调用此函数，以提示哈希值以及过期，内核下一次访问哈希或者调用bpf_get_hash_recalc时会触发哈希值的重新计算。

## bpf_get_hash_recalc
签名： `u32 bpf_get_hash_recalc(struct sk_buff *skb)`

获取封包哈希值 skb->hash，如果该字段没有设置（特别是因为封包修改导致哈希被清空）则计算并设置哈希。后续可以直接访问skb->哈希获取哈希值。

调用bpf_set_hash_invalid()、bpf_skb_change_proto()、bpf_skb_store_bytes()+BPF_F_INVALIDATE_HASH标记，都会导致哈希值清空，并导致下一次bpf_get_hash_recalc()调用重新生成哈希值。

## bpf_set_hash
签名： `u32 bpf_set_hash(struct sk_buff *skb, u32 hash)`

设置完整哈希值到skb->hash

## bpf_skb_change_tail
签名： `int bpf_skb_change_tail(struct sk_buff *skb, u32 len, u64 flags)`

Resize(trim/grow) skb关联的封包到len长。flags必须置零。

改变封包长度后，eBPF程序可能需要调用bpf_skb_store_bytes、bpf_l3_csum_replace、bpf_l3_csum_replace等函数填充数据、重新计算Checksum。

一般用于回复ICMP控制报文。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_skb_pull_data
签名： `int bpf_skb_pull_data(struct sk_buff *skb, u32 len)`

所谓non-linear的skb，是指被fragmented的skb，即有一部分数据没有存放在skb所在内存，而是存放在其它内存页（可能有多个），并通过skb_shared_info记录这些数据位置。

当skb是non-linear的、并且不是所有len长是linear section的一部分的前提下，拉取skb的non-linear数据。确保skb的len字节是可读写的。如果len设置为0，则拉取拉取skb的整个长度的数据。

进行封包直接访问时，通过 skb->data_end来测试某个偏移量是否在封包范围内，可能因为两个原因失败：

偏移量是无效的
偏移量对应的数据是在skb的non-linear部分中
该助手函数可以用来一次性拉取non-linear数据，然后再进行偏移量测试和数据访问。

此函数确保skb是uncloned，这是直接封包访问的前提。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_get_socket_cookie
签名： `u64 bpf_get_socket_cookie(struct sk_buff *skb)`

如果skb关联到一个已知的套接字，则得到套接字的cookie（由内核生成），如果尚未设置cookie，则生成之。一旦cookie生成，在套接字的生命周期范围内都不会改变。

该助手用于监控套接字网络流量统计信息，它在网络命名空间范围内为套接字提供唯一标识。

## bpf_get_socket_uid
签名： `u32 bpf_get_socket_uid(struct sk_buff *skb)`

获得套接字的owner UID。如果套接字是NULL，或者不是full socket（time-wait状态，或者是一个request socket），则返回overflowuid，overflowuid不一定是socket的实际UID。

## bpf_csum_update
签名： `s64 bpf_csum_update(struct sk_buff *skb, __wsum csum)`

如果驱动已经为整个封包提供了Checksum，那么此函数将csum加到 skb->csum字段上，其它情况下返回错误。

该助手函数应当和 bpf_csum_diff()联合使用，典型场景是，通过封包直接访问修改了封包内容之后，进行Checksum更新。

## bpf_get_route_realm
签名： `u32 bpf_get_route_realm(struct sk_buff *skb)`

得到路由的Realm，也就是skb的destination的tclassid字段。这个字段是用户提供的一个tag，类似于net_cls的classid。不同的是，这里的tag关联到路由条目（destination entry）。

可以在clsact TC egress钩子中调用此函数，或者在经典的classful egress qdiscs上使用。不能在TC ingress路径上使用。

要求内核配置选项CONFIG_IP_ROUTE_CLASSID。

返回skb关联的封包的路由的realm。

## bpf_setsockopt
签名： `int bpf_setsockopt(struct bpf_sock_ops *bpf_socket, int level, int optname, char *optval, int optlen)`

针对bpf_socket关联的套接字发起一个setsockopt()操作，此套接字必须是full socket。optname为选项名，optval/optlen指定了选项值，level指定了选项的位置。

该函数实际上实现了setsockopt()的子集，支持以下level：
- SOL_SOCKET，支持选项SO_RCVBUF, SO_SNDBUF, SO_MAX_PACING_RATE, SO_PRIORITY, SO_RCVLOWAT, SO_MARK
- IPPROTO_TCP，支持选项TCP_CONGESTION, TCP_BPF_IW, TCP_BPF_SNDCWND_CLAMP
- IPPROTO_IP，支持选项IP_TOS
- IPPROTO_IPV6，支持选项IPV6_TCLASS

## bpf_skb_adjust_room
签名：` int bpf_skb_adjust_room(struct sk_buff *skb, u32 len_diff, u32 mode, u64 flags)`

增加/缩小skb关联的封包的数据的room，增量为len_diff。mode可以是：

BPF_ADJ_ROOM_NET，在网络层调整room，即在L3头上增加/移除room space
flags必须置零。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_xdp_adjust_head
签名： `int bpf_xdp_adjust_head(struct xdp_buff *xdp_md, int delta)`

移动 xdp_md->data delta字节，delta可以是负数。

该函数准备用于push/pop headers的封包。

调用此助手函数会导致封包缓冲区改变，因此在加载期间校验器对指针的校验将失效，必须重新校验。

## bpf_xdp_adjust_meta
签名： `int bpf_xdp_adjust_meta(struct xdp_buff *xdp_md, int delta)`

调整 xdp_md->data_meta所指向的地址delta字节。该操作改变了存储在xdp_md->data中的地址信息。

## bpf_get_current_task
签名： `u64 bpf_get_current_task(void)`

获取当前Task结构的指针。

## bpf_get_stackid
签名： `int bpf_get_stackid(struct pt_reg *ctx, struct bpf_map *map, u64 flags)`

获取一个用户/内核栈，得到其ID。需要传入ctx，即当前追踪程序在其中执行的上下文对象，以及一个BPF_MAP_TYPE_STACK_TRACE类型的Map。通过flags指示需要跳过多少栈帧（0-255），masked with BPF_F_SKIP_FIELD_MASK。flags的其它位如下：
- BPF_F_USER_STACK 收集用户空间的栈，而非内核栈
- BPF_F_FAST_STACK_CMP 基于哈希来对比栈
- BPF_F_REUSE_STACKID 如果两个不同的栈哈希到同一个stackid，丢弃旧的

## bpf_get_current_pid_tgid
签名： `u64 bpf_get_current_pid_tgid(void)`

返回一个包含了当前tgid和pid的64bit整数。值为 current_task->tgid << 32 | current_task->pid

## bpf_get_current_uid_gid
签名： `u64 bpf_get_current_uid_gid(void)`

返回一个包含了当前GID和UID的整数。值为 current_gid << 32 | current_uid

## bpf_get_current_comm
签名： `int bpf_get_current_comm(char *buf, u32 size_of_buf)`

将当前任务的comm属性拷贝到长度为size_of_buf的buf中。comm属性包含可执行文件的路径

调用成功时助手函数确保buf是NULL-terminated。如果失败，则填满0

## bpf_get_cgroup_classid
签名： `u32 bpf_get_cgroup_classid(struct sk_buff *skb)`

得到当前任务的classid，即skb所属的net_cls控制组的classid。该助手函数可用于TC的egress路径，不能用于ingress路径。

Linux支持两个版本的Cgroups，v1和v2，用户可以混合使用。但是，net_cls是v1特有的Cgroup。这意味着此助手函数和run on cgroups（v2 only）的eBPF程序不兼容，套接字一次仅仅能携带一个版本Cgroup的数据。

内核必须配置CONFIG_CGROUP_NET_CLASSID=y/m才能使用此助手函数。

返回classid，或者0，即默认的没有被配置的classid。

## bpf_probe_write_user
签名： `int bpf_probe_write_user(void *dst, const void *src, u32 len)`

尝试在以一个安全方式来写入src的len字节到dst中。仅仅对于运行在用户上下文的线程可用，dst必须是有效的用户空间地址。

由于TOC-TOU攻击的原因，此助手函数不得用于实现任何类型的安全机制。

此函数用于试验目的，存在的导致系统、进程崩溃的风险。当调用了此函数的eBPF程序被挂钩后，内核日志会打印一条警告信息，包含PID和进程名信息。

## bpf_probe_read_str
签名： `int bpf_probe_read_str(void *dst, int size, const void *unsafe_ptr)`

从unsafe_ptr拷贝一个NULL结尾的字符串到dst，size包含结尾的NULL字符。如果字符串长度小于size，不会补NUL；如果字符串长度大于size，则截断（保证填充字符串结尾NULL）

## bpf_current_task_under_cgroup
签名： `int bpf_current_task_under_cgroup(struct bpf_map *map, u32 index)`

检查当前正在运行的探针是否在map的index所指向的Cgroup2之下。

## bpf_get_numa_node_id
签名： `int bpf_get_numa_node_id(void)`

得到当前NUMA节点的ID。该函数的主要目的是用于选取本地NUMA节点的套接字。

## bpf_perf_event_output
签名： `int bpf_perf_event_output(struct pt_reg *ctx, struct bpf_map *map, u64 flags, void *data, u64 size)`

将长度为size的blob写入到Map所存放的特殊BPF perf event。map的类型是BPF_MAP_TYPE_PERF_EVENT_ARRAY

perf event必须具有属性：
- sample_type = PERF_SAMPLE_RAW
- type = PERF_TYPE_SOFTWARE
- config = PERF_COUNT_SW_BPF_OUTPUT

flags用于指定写入到数组的索引。masked by BPF_F_INDEX_MASK，如果指定BPF_F_CURRENT_CPU则取当前CPU的值。

当前程序的ctx也需要传递给助手函数。

在用户空间，希望读取值的程序需要针对perf event调用perf_event_open() ，然后将文件描述符存储到Map中。这个操作必须在eBPF程序第一次写入数据到Map之前完成。参考内核中的例子samples/bpf/trace_output_user.c 

要和用户空间进行数据交互，该函数优于bpf_trace_printk()，性能更好。适合从eBPF程序stream数据给用户空间读取。

## bpf_perf_event_read
签名： `u64 bpf_perf_event_read(struct bpf_map *map, u64 flags)`

读取一个perf event counter的值，该助手函数操作BPF_MAP_TYPE_PERF_EVENT_ARRAY类型的Map。这个Map本质上是一个数组，它的size和CPU数量一致，其值和对应CPU相关。取哪个CPU的值，masked by BPF_F_INDEX_MASK，如果指定BPF_F_CURRENT_CPU则取当前CPU的值。

在4.13之前，仅仅支持hardware perf event。

成功时返回计数器值，否则返回负数。

考虑使用 bpf_perf_event_read_value代替此函数。

## References
1. [绿色记忆:eBPF学习笔记](https://blog.gmem.cc/ebpf)