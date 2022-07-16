---
title: BPF ringbuffer APIs
date: 2021-11-01 14:55
modify: 星期一 1日 十一月 2021 14:55:51
author: edony.zpc
tags: 001-computer-technology
---

# BPF ringbuffer APIs
## perfbuf
### kernelspace
`bpf_perf_event_output()`

This API reserves the space for struct event in perf buffer on the current CPU, copies `sizeof(*e)` bytes of data from e to that reserved space, and when done it will signal user-space that the new data is available. At that point epoll subsystem will wakeup the user-space handler and will pass the pointer to that copy of data for processing.

### userspace
```c
/* Set up libbpf logging callback */
libbpf_set_print(libbpf_print_fn);
/* Bump RLIMIT_MEMLOCK to create BPF maps */
bump_memlock_rlimit();
/* Set up ring buffer polling */
struct perf_buffer *pb = NULL;
struct perf_buffer_opts pb_opts = {};
struct perfbuf_output_bpf *skel;	// load & attach
/* void handle_event(void *ctx, int cpu, void *data, unsigned int data_sz); */
pb_opts.sample_cb = handle_event;
perf_buffer__new(bpf_map__fd(skel->maps.pb), 8 /* 32KB per CPU */, &pb_opts);
/* Process events */
perf_buffer__poll(pb, 100 /* timeout, ms */);
```

 After doing a minimal initial setup (setting libbpf logging handler, interrupt handler, bumping `RLIMIT_MEMLOCK` limit for BPF system), it just opens and loads the BPF skeleton. If all that succeeds, we then use libbpf's user-space `perf_buffer__new()` API to create an instance of perf buffer consumer.

## ringbuf
### kernelspace
`bpf_ringbuf_output()`

This API is designed to follow the semantics of BPF perfbuf's `bpf_perf_event_output()` to make the migration a complete no-brainer. To show how similar and close the usability is, I'll literally show the diff between the perfbuf-output and ringbuf-output examples.
```diff
--- src/perfbuf-output.bpf.c	2020-10-25 18:52:22.247019800 -0700
+++ src/ringbuf-output.bpf.c	2020-10-25 18:44:14.510630322 -0700
@@ -6,12 +6,11 @@
 
 char LICENSE[] SEC("license") = "Dual BSD/GPL";
 
-/* BPF perfbuf map */
+/* BPF ringbuf map */
 struct {
-	__uint(type, BPF_MAP_TYPE_PERF_EVENT_ARRAY);
-	__uint(key_size, sizeof(int));
-	__uint(value_size, sizeof(int));
-} pb SEC(".maps");
+	__uint(type, BPF_MAP_TYPE_RINGBUF);
+	__uint(max_entries, 256 * 1024 /* 256 KB */);
+} rb SEC(".maps");
 
 struct {
 	__uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
@@ -35,7 +34,7 @@
 	bpf_get_current_comm(&e->comm, sizeof(e->comm));
 	bpf_probe_read_str(&e->filename, sizeof(e->filename), (void *)ctx + fname_off);
 
-	bpf_perf_event_output(ctx, &pb, BPF_F_CURRENT_CPU, e, sizeof(*e));
+	bpf_ringbuf_output(&rb, e, sizeof(*e), 0);
 	return 0;
 }
```
So just two simple changes:
- BPF ringbuf map is defined slightly differently. Its size (but now it's the size of the buffer shared across all CPUs) can be now defined on the BPF side. Keep in mind, it's still possible to omit it in BPF-side definition and specify (or override if you do specify it on BPF side) on user-space side with `bpf_map__set_max_entries()` API. The other difference is that the size (max_entries property) is specified in number of bytes, with the only restriction being that it should be a multiple of kernel page size (almost always 4096 bytes) and a power of 2 (similarly as for perfbuf's number of pages, which also has to be a power of 2). The BPF perfbuf size is specified from the user-space side and is in a number of memory pages.
- `bpf_perf_event_output()` is replaced with the very similar `bpf_ringbuf_output()`, with the only difference that ringbuf API doesn't need a reference to the BPF program's context.

### userspace
On the user-space side the changes are also minimal. Ignoring `perf_buffer` <-> `ring_buffer` renames, it comes down to just two changes. 
#### 1. event handle definition
```diff
-void handle_event(void *ctx, int cpu, void *data, unsigned int data_sz)
+int handle_event(void *ctx, void *data, size_t data_sz)
{
	const struct event *e = data;
	struct tm *tm;
```

#### 2. ring_buffer_new definition
`ring_buffer__new()` API, which allows specifying callback without resorting to extra options struct:
```diff
 	/* Set up ring buffer polling */
-	pb_opts.sample_cb = handle_event;
-	pb = perf_buffer__new(bpf_map__fd(skel->maps.pb), 8 /* 32KB per CPU */, &pb_opts);
-	if (libbpf_get_error(pb)) {
+	rb = ring_buffer__new(bpf_map__fd(skel->maps.rb), handle_event, NULL, NULL);
+	if (!rb) {
 		err = -1;
-		fprintf(stderr, "Failed to create perf buffer\n");
+		fprintf(stderr, "Failed to create ring buffer\n");
 		goto cleanup;
 	}
```

#### 3. ringbuf poll
simply replacing `perf_buffer__poll()` with `ring_buffer__poll()` allows you to start consuming ring buffer data in exactly the same way:
```diff
 	printf("%-8s %-5s %-7s %-16s %s\n",
 	       "TIME", "EVENT", "PID", "COMM", "FILENAME");
 	while (!exiting) {
-		err = perf_buffer__poll(pb, 100 /* timeout, ms */);
+		err = ring_buffer__poll(rb, 100 /* timeout, ms */);
 		/* Ctrl-C will cause -EINTR */
 		if (err == -EINTR) {
 			err = 0;
 			break;
 		}
 		if (err < 0) {
-			printf("Error polling perf buffer: %d\n", err);
+			printf("Error polling ring buffer: %d\n", err);
 			break;
 		}
 	}
```

### reserve/submmit API
`bpf_ringbuf_output()` API was to allow a smooth transition from BPF perfbuf to BPF ringbuf without any substantial changes to BPF code. But it also means that it shares some of the shortcomings of BPF perfbuf APIs: extra memory copy and very late data reservation. `bpf_ringbuf_reserve()`/`bpf_ringbuf_submmit()` APIs come in handy. Reserve allows you to do just that: reserve the space early on or determine that it's not possible (returning NULL in such case). If we can't get enough data to submit the sample, we can skip spending all the resources to capture data. But if the reservation succeeded, then we have a guarantee that, once we are done with data collection, publishing it to the user-space will never fail. I.e., if `bpf_ringbuf_reserve()` returns a non-NULL pointer, subsequent `bpf_ringbuf_submmit()` will always succeed.
```diff
--- src/ringbuf-output.bpf.c	2020-10-25 18:44:14.510630322 -0700
+++ src/ringbuf-reserve-submit.bpf.c	2020-10-25 18:36:53.409470270 -0700
@@ -12,29 +12,21 @@
 	__uint(max_entries, 256 * 1024 /* 256 KB */);
 } rb SEC(".maps");
 
-struct {
-	__uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
-	__uint(max_entries, 1);
-	__type(key, int);
-	__type(value, struct event);
-} heap SEC(".maps");
-
 SEC("tp/sched/sched_process_exec")
 int handle_exec(struct trace_event_raw_sched_process_exec *ctx)
 {
 	unsigned fname_off = ctx->__data_loc_filename & 0xFFFF;
 	struct event *e;
-	int zero = 0;
 	
-	e = bpf_map_lookup_elem(&heap, &zero);
-	if (!e) /* can't happen */
+	e = bpf_ringbuf_reserve(&rb, sizeof(*e), 0);
+	if (!e)
 		return 0;
 
 	e->pid = bpf_get_current_pid_tgid() >> 32;
 	bpf_get_current_comm(&e->comm, sizeof(e->comm));
 	bpf_probe_read_str(&e->filename, sizeof(e->filename), (void *)ctx + fname_off);
 
-	bpf_ringbuf_output(&rb, e, sizeof(*e), 0);
+	bpf_ringbuf_submit(e, 0);
 	return 0;
 }
```

### data notification control
When dealing with high-throughput cases, often the biggest overhead comes from in-kernel signalling of data availability when a sample is submitted (this lets kernel’s poll/epoll system to wake up user-space handlers blocked on waiting for the new data). This is true for both perfbuf and ringbuf.

Perfbuf handles that with the ability to set up sampled notification, in which case only every Nth sample will send a notification. You can do that when creating a BPF perfbuf map from the user-space. And you need to make sure that it works for you that you won’t see the last N-1 samples, until the Nth sample arrives. This might or might not be a big deal for your particular case.

BPF ringbuf went a different route with this. `bpf_ringbuf_output()` and `bpf_ringbuf_submmit()` accept an extra flags argument and you can specify either `BPF_RB_NO_WAKEUP` or `BPF_RB_FORCE_WAKEUP` flag. Specifying `BPF_RB_NO_WAKEUP` inhibits sending in-kernel data availability notification. While `BPF_RB_FORCE_WAKEUP` will force sending a notification. This allows for the precise manual control, if necessary. To see how that can be done, please check BPF ringbuf benchmark, which will send notifications only when a configurable amount of data is enqueued in the ring buffer.

By default, if no flag is specified, BPF ringbuf code will do an adaptive notification depending on whether the user-space consumer is lagging behind or not, which results in the user-space consumer never missing a single sample notification, but not paying unnecessary overhead. No flag is a good and safe default, but if you need to get an extra performance, manually controlling data notifications depending on your custom criteria (e.g., amount of enqueued data in the buffer) might give you a big boost in performance.

## References
1. [BPF ring buffer](https://nakryiko.com/posts/bpf-ringbuf/)