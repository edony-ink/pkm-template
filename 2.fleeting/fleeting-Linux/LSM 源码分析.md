---
title: LSM 源码分析
date: 2021-09-28 19:06
modify: 星期二 28日 九月 2021 19:06:22
author: edony.zpc
tags: 001-computer-technology
---

# LSM 源码分析
## 1. LSM初始化

```c
/**
 * security_init - initializes the security framework
 *
 * This should be called early in the kernel initialization sequence.
 */
int __init security_init(void)
{
	int i;
	struct hlist_head *list = (struct hlist_head *) &security_hook_heads;

	pr_info("Security Framework initializing\n");

	/* 初始化hook list用来保存hook点 */
	for (i = 0; i < sizeof(security_hook_heads) / sizeof(struct hlist_head);
	     i++)
		INIT_HLIST_HEAD(&list[i]);

	/**
	 * LSM分为major和minor两种，major具备排他性（SELinux,AppArmor,TOMOYO），
	 * major LSM都是一种MAC实现，所以通过用户态配置来加载。LSM实现的排他性通过
	 * LSM_FLAG_EXCLUSIVE控制。
	 */
	/*
	 * Load minor LSMs, with the capability module always first.
	 */
	capability_add_hooks();
	yama_add_hooks();
	loadpin_add_hooks();

    /* 根据cmdline和builtin配置参数加载具体的LSM模块，例如SELinux */
	/* Load LSMs in specified order. */
	ordered_lsm_init();

	return 0;
}

/* Initialize a given LSM, if it is enabled. */
static void __init initialize_lsm(struct lsm_info *lsm)
{
	if (is_enabled(lsm)) {
		int ret;

		init_debug("initializing %s\n", lsm->name);
		ret = lsm->init();
		WARN(ret, "%s failed to initialize: %d\n", lsm->name, ret);
	}
}
```

## 2. LSM模块（以SELinux模块为例）
```c
/* ------------------------------------------------------------- */
/* 以SELinux模块为例看LSM的初始化 */
/* SELinux requires early initialization in order to label
   all processes and objects when they are created. */
DEFINE_LSM(selinux) = {
	.name = "selinux",
	.flags = LSM_FLAG_LEGACY_MAJOR | LSM_FLAG_EXCLUSIVE,
	.enabled = &selinux_enabled,
	.init = selinux_init,
};
static __init int selinux_init(void)
{
	pr_info("SELinux:  Initializing.\n");

	memset(&selinux_state, 0, sizeof(selinux_state));
	enforcing_set(&selinux_state, selinux_enforcing_boot);
	selinux_state.checkreqprot = selinux_checkreqprot_boot;
	selinux_ss_init(&selinux_state.ss);
	selinux_avc_init(&selinux_state.avc);

	/* Set the security state for the initial task. */
	cred_init_security();

	default_noexec = !(VM_DATA_DEFAULT_FLAGS & VM_EXEC);

	sel_inode_cache = kmem_cache_create("selinux_inode_security",
					    sizeof(struct inode_security_struct),
					    0, SLAB_PANIC, NULL);
	file_security_cache = kmem_cache_create("selinux_file_security",
					    sizeof(struct file_security_struct),
					    0, SLAB_PANIC, NULL);
	avc_init();

	avtab_cache_init();

	ebitmap_cache_init();

	hashtab_cache_init();

	/* 增加SELinux的勾子点 */
	security_add_hooks(selinux_hooks, ARRAY_SIZE(selinux_hooks), "selinux");

	if (avc_add_callback(selinux_netcache_avc_callback, AVC_CALLBACK_RESET))
		panic("SELinux: Unable to register AVC netcache callback\n");

	if (avc_add_callback(selinux_lsm_notifier_avc_callback, AVC_CALLBACK_RESET))
		panic("SELinux: Unable to register AVC LSM notifier callback\n");

	if (selinux_enforcing_boot)
		pr_debug("SELinux:  Starting in enforcing mode\n");
	else
		pr_debug("SELinux:  Starting in permissive mode\n");

	return 0;
}
/* SELinux 定义的勾子链表 */
static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
	LSM_HOOK_INIT(binder_set_context_mgr, selinux_binder_set_context_mgr),
	LSM_HOOK_INIT(binder_transaction, selinux_binder_transaction),
	LSM_HOOK_INIT(binder_transfer_binder, selinux_binder_transfer_binder),
	LSM_HOOK_INIT(binder_transfer_file, selinux_binder_transfer_file),

	LSM_HOOK_INIT(ptrace_access_check, selinux_ptrace_access_check),
	LSM_HOOK_INIT(ptrace_traceme, selinux_ptrace_traceme),
	LSM_HOOK_INIT(capget, selinux_capget),
	LSM_HOOK_INIT(capset, selinux_capset),
	LSM_HOOK_INIT(capable, selinux_capable),
	LSM_HOOK_INIT(quotactl, selinux_quotactl),
	LSM_HOOK_INIT(quota_on, selinux_quota_on),
	LSM_HOOK_INIT(syslog, selinux_syslog),
	LSM_HOOK_INIT(vm_enough_memory, selinux_vm_enough_memory),

	LSM_HOOK_INIT(netlink_send, selinux_netlink_send),

	LSM_HOOK_INIT(bprm_set_creds, selinux_bprm_set_creds),
	LSM_HOOK_INIT(bprm_committing_creds, selinux_bprm_committing_creds),
	LSM_HOOK_INIT(bprm_committed_creds, selinux_bprm_committed_creds),

	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),
	LSM_HOOK_INIT(sb_remount, selinux_sb_remount),
	LSM_HOOK_INIT(sb_kern_mount, selinux_sb_kern_mount),
	LSM_HOOK_INIT(sb_show_options, selinux_sb_show_options),
	LSM_HOOK_INIT(sb_statfs, selinux_sb_statfs),
	LSM_HOOK_INIT(sb_mount, selinux_mount),
	LSM_HOOK_INIT(sb_umount, selinux_umount),
	LSM_HOOK_INIT(sb_set_mnt_opts, selinux_set_mnt_opts),
	LSM_HOOK_INIT(sb_clone_mnt_opts, selinux_sb_clone_mnt_opts),
	LSM_HOOK_INIT(sb_parse_opts_str, selinux_parse_opts_str),

	LSM_HOOK_INIT(dentry_init_security, selinux_dentry_init_security),
	LSM_HOOK_INIT(dentry_create_files_as, selinux_dentry_create_files_as),

	LSM_HOOK_INIT(inode_alloc_security, selinux_inode_alloc_security),
	LSM_HOOK_INIT(inode_free_security, selinux_inode_free_security),
	LSM_HOOK_INIT(inode_init_security, selinux_inode_init_security),
	LSM_HOOK_INIT(inode_create, selinux_inode_create),
	LSM_HOOK_INIT(inode_link, selinux_inode_link),
	LSM_HOOK_INIT(inode_unlink, selinux_inode_unlink),
	LSM_HOOK_INIT(inode_symlink, selinux_inode_symlink),
	LSM_HOOK_INIT(inode_mkdir, selinux_inode_mkdir),
	LSM_HOOK_INIT(inode_rmdir, selinux_inode_rmdir),
	LSM_HOOK_INIT(inode_mknod, selinux_inode_mknod),
	LSM_HOOK_INIT(inode_rename, selinux_inode_rename),
	LSM_HOOK_INIT(inode_readlink, selinux_inode_readlink),
	LSM_HOOK_INIT(inode_follow_link, selinux_inode_follow_link),
	LSM_HOOK_INIT(inode_permission, selinux_inode_permission),
	LSM_HOOK_INIT(inode_setattr, selinux_inode_setattr),
	LSM_HOOK_INIT(inode_getattr, selinux_inode_getattr),
	LSM_HOOK_INIT(inode_setxattr, selinux_inode_setxattr),
	LSM_HOOK_INIT(inode_post_setxattr, selinux_inode_post_setxattr),
	LSM_HOOK_INIT(inode_getxattr, selinux_inode_getxattr),
	LSM_HOOK_INIT(inode_listxattr, selinux_inode_listxattr),
	LSM_HOOK_INIT(inode_removexattr, selinux_inode_removexattr),
	LSM_HOOK_INIT(inode_getsecurity, selinux_inode_getsecurity),
	LSM_HOOK_INIT(inode_setsecurity, selinux_inode_setsecurity),
	LSM_HOOK_INIT(inode_listsecurity, selinux_inode_listsecurity),
	LSM_HOOK_INIT(inode_getsecid, selinux_inode_getsecid),
	LSM_HOOK_INIT(inode_copy_up, selinux_inode_copy_up),
	LSM_HOOK_INIT(inode_copy_up_xattr, selinux_inode_copy_up_xattr),

	LSM_HOOK_INIT(file_permission, selinux_file_permission),
	LSM_HOOK_INIT(file_alloc_security, selinux_file_alloc_security),
	LSM_HOOK_INIT(file_free_security, selinux_file_free_security),
	LSM_HOOK_INIT(file_ioctl, selinux_file_ioctl),
	LSM_HOOK_INIT(mmap_file, selinux_mmap_file),
	LSM_HOOK_INIT(mmap_addr, selinux_mmap_addr),
	LSM_HOOK_INIT(file_mprotect, selinux_file_mprotect),
	LSM_HOOK_INIT(file_lock, selinux_file_lock),
	LSM_HOOK_INIT(file_fcntl, selinux_file_fcntl),
	LSM_HOOK_INIT(file_set_fowner, selinux_file_set_fowner),
	LSM_HOOK_INIT(file_send_sigiotask, selinux_file_send_sigiotask),
	LSM_HOOK_INIT(file_receive, selinux_file_receive),

	/**
	 * 在LSM框架管理的勾子链表中增加file_open，其中勾子函数为
	 * selinux_file_open，即:
	 * file_open = head_list{
	 * 	 .head=security_hook_heads,
	 * 	 .hook=head_list{
	 *		 .head=selinux_file_open,
	 *	 }
	 * };
	 */
	LSM_HOOK_INIT(file_open, selinux_file_open),

	LSM_HOOK_INIT(task_alloc, selinux_task_alloc),
	LSM_HOOK_INIT(cred_alloc_blank, selinux_cred_alloc_blank),
	LSM_HOOK_INIT(cred_free, selinux_cred_free),
	LSM_HOOK_INIT(cred_prepare, selinux_cred_prepare),
	LSM_HOOK_INIT(cred_transfer, selinux_cred_transfer),
	LSM_HOOK_INIT(cred_getsecid, selinux_cred_getsecid),
	LSM_HOOK_INIT(kernel_act_as, selinux_kernel_act_as),
	LSM_HOOK_INIT(kernel_create_files_as, selinux_kernel_create_files_as),
	LSM_HOOK_INIT(kernel_module_request, selinux_kernel_module_request),
	LSM_HOOK_INIT(kernel_load_data, selinux_kernel_load_data),
	LSM_HOOK_INIT(kernel_read_file, selinux_kernel_read_file),
	LSM_HOOK_INIT(task_setpgid, selinux_task_setpgid),
	LSM_HOOK_INIT(task_getpgid, selinux_task_getpgid),
	LSM_HOOK_INIT(task_getsid, selinux_task_getsid),
	LSM_HOOK_INIT(task_getsecid, selinux_task_getsecid),
	LSM_HOOK_INIT(task_setnice, selinux_task_setnice),
	LSM_HOOK_INIT(task_setioprio, selinux_task_setioprio),
	LSM_HOOK_INIT(task_getioprio, selinux_task_getioprio),
	LSM_HOOK_INIT(task_prlimit, selinux_task_prlimit),
	LSM_HOOK_INIT(task_setrlimit, selinux_task_setrlimit),
	LSM_HOOK_INIT(task_setscheduler, selinux_task_setscheduler),
	LSM_HOOK_INIT(task_getscheduler, selinux_task_getscheduler),
	LSM_HOOK_INIT(task_movememory, selinux_task_movememory),
	LSM_HOOK_INIT(task_kill, selinux_task_kill),
	LSM_HOOK_INIT(task_to_inode, selinux_task_to_inode),

	LSM_HOOK_INIT(ipc_permission, selinux_ipc_permission),
	LSM_HOOK_INIT(ipc_getsecid, selinux_ipc_getsecid),

	LSM_HOOK_INIT(msg_msg_alloc_security, selinux_msg_msg_alloc_security),
	LSM_HOOK_INIT(msg_msg_free_security, selinux_msg_msg_free_security),

	LSM_HOOK_INIT(msg_queue_alloc_security,
			selinux_msg_queue_alloc_security),
	LSM_HOOK_INIT(msg_queue_free_security, selinux_msg_queue_free_security),
	LSM_HOOK_INIT(msg_queue_associate, selinux_msg_queue_associate),
	LSM_HOOK_INIT(msg_queue_msgctl, selinux_msg_queue_msgctl),
	LSM_HOOK_INIT(msg_queue_msgsnd, selinux_msg_queue_msgsnd),
	LSM_HOOK_INIT(msg_queue_msgrcv, selinux_msg_queue_msgrcv),

	LSM_HOOK_INIT(shm_alloc_security, selinux_shm_alloc_security),
	LSM_HOOK_INIT(shm_free_security, selinux_shm_free_security),
	LSM_HOOK_INIT(shm_associate, selinux_shm_associate),
	LSM_HOOK_INIT(shm_shmctl, selinux_shm_shmctl),
	LSM_HOOK_INIT(shm_shmat, selinux_shm_shmat),

	LSM_HOOK_INIT(sem_alloc_security, selinux_sem_alloc_security),
	LSM_HOOK_INIT(sem_free_security, selinux_sem_free_security),
	LSM_HOOK_INIT(sem_associate, selinux_sem_associate),
	LSM_HOOK_INIT(sem_semctl, selinux_sem_semctl),
	LSM_HOOK_INIT(sem_semop, selinux_sem_semop),

	LSM_HOOK_INIT(d_instantiate, selinux_d_instantiate),

	LSM_HOOK_INIT(getprocattr, selinux_getprocattr),
	LSM_HOOK_INIT(setprocattr, selinux_setprocattr),

	LSM_HOOK_INIT(ismaclabel, selinux_ismaclabel),
	LSM_HOOK_INIT(secid_to_secctx, selinux_secid_to_secctx),
	LSM_HOOK_INIT(secctx_to_secid, selinux_secctx_to_secid),
	LSM_HOOK_INIT(release_secctx, selinux_release_secctx),
	LSM_HOOK_INIT(inode_invalidate_secctx, selinux_inode_invalidate_secctx),
	LSM_HOOK_INIT(inode_notifysecctx, selinux_inode_notifysecctx),
	LSM_HOOK_INIT(inode_setsecctx, selinux_inode_setsecctx),
	LSM_HOOK_INIT(inode_getsecctx, selinux_inode_getsecctx),

	LSM_HOOK_INIT(unix_stream_connect, selinux_socket_unix_stream_connect),
	LSM_HOOK_INIT(unix_may_send, selinux_socket_unix_may_send),

	LSM_HOOK_INIT(socket_create, selinux_socket_create),
	LSM_HOOK_INIT(socket_post_create, selinux_socket_post_create),
	LSM_HOOK_INIT(socket_socketpair, selinux_socket_socketpair),
	LSM_HOOK_INIT(socket_bind, selinux_socket_bind),
	LSM_HOOK_INIT(socket_connect, selinux_socket_connect),
	LSM_HOOK_INIT(socket_listen, selinux_socket_listen),
	LSM_HOOK_INIT(socket_accept, selinux_socket_accept),
	LSM_HOOK_INIT(socket_sendmsg, selinux_socket_sendmsg),
	LSM_HOOK_INIT(socket_recvmsg, selinux_socket_recvmsg),
	LSM_HOOK_INIT(socket_getsockname, selinux_socket_getsockname),
	LSM_HOOK_INIT(socket_getpeername, selinux_socket_getpeername),
	LSM_HOOK_INIT(socket_getsockopt, selinux_socket_getsockopt),
	LSM_HOOK_INIT(socket_setsockopt, selinux_socket_setsockopt),
	LSM_HOOK_INIT(socket_shutdown, selinux_socket_shutdown),
	LSM_HOOK_INIT(socket_sock_rcv_skb, selinux_socket_sock_rcv_skb),
	LSM_HOOK_INIT(socket_getpeersec_stream,
			selinux_socket_getpeersec_stream),
	LSM_HOOK_INIT(socket_getpeersec_dgram, selinux_socket_getpeersec_dgram),
	LSM_HOOK_INIT(sk_alloc_security, selinux_sk_alloc_security),
	LSM_HOOK_INIT(sk_free_security, selinux_sk_free_security),
	LSM_HOOK_INIT(sk_clone_security, selinux_sk_clone_security),
	LSM_HOOK_INIT(sk_getsecid, selinux_sk_getsecid),
	LSM_HOOK_INIT(sock_graft, selinux_sock_graft),
	LSM_HOOK_INIT(sctp_assoc_request, selinux_sctp_assoc_request),
	LSM_HOOK_INIT(sctp_sk_clone, selinux_sctp_sk_clone),
	LSM_HOOK_INIT(sctp_bind_connect, selinux_sctp_bind_connect),
	LSM_HOOK_INIT(inet_conn_request, selinux_inet_conn_request),
	LSM_HOOK_INIT(inet_csk_clone, selinux_inet_csk_clone),
	LSM_HOOK_INIT(inet_conn_established, selinux_inet_conn_established),
	LSM_HOOK_INIT(secmark_relabel_packet, selinux_secmark_relabel_packet),
	LSM_HOOK_INIT(secmark_refcount_inc, selinux_secmark_refcount_inc),
	LSM_HOOK_INIT(secmark_refcount_dec, selinux_secmark_refcount_dec),
	LSM_HOOK_INIT(req_classify_flow, selinux_req_classify_flow),
	LSM_HOOK_INIT(tun_dev_alloc_security, selinux_tun_dev_alloc_security),
	LSM_HOOK_INIT(tun_dev_free_security, selinux_tun_dev_free_security),
	LSM_HOOK_INIT(tun_dev_create, selinux_tun_dev_create),
	LSM_HOOK_INIT(tun_dev_attach_queue, selinux_tun_dev_attach_queue),
	LSM_HOOK_INIT(tun_dev_attach, selinux_tun_dev_attach),
	LSM_HOOK_INIT(tun_dev_open, selinux_tun_dev_open),
#ifdef CONFIG_SECURITY_INFINIBAND
	LSM_HOOK_INIT(ib_pkey_access, selinux_ib_pkey_access),
	LSM_HOOK_INIT(ib_endport_manage_subnet,
		      selinux_ib_endport_manage_subnet),
	LSM_HOOK_INIT(ib_alloc_security, selinux_ib_alloc_security),
	LSM_HOOK_INIT(ib_free_security, selinux_ib_free_security),
#endif
#ifdef CONFIG_SECURITY_NETWORK_XFRM
	LSM_HOOK_INIT(xfrm_policy_alloc_security, selinux_xfrm_policy_alloc),
	LSM_HOOK_INIT(xfrm_policy_clone_security, selinux_xfrm_policy_clone),
	LSM_HOOK_INIT(xfrm_policy_free_security, selinux_xfrm_policy_free),
	LSM_HOOK_INIT(xfrm_policy_delete_security, selinux_xfrm_policy_delete),
	LSM_HOOK_INIT(xfrm_state_alloc, selinux_xfrm_state_alloc),
	LSM_HOOK_INIT(xfrm_state_alloc_acquire,
			selinux_xfrm_state_alloc_acquire),
	LSM_HOOK_INIT(xfrm_state_free_security, selinux_xfrm_state_free),
	LSM_HOOK_INIT(xfrm_state_delete_security, selinux_xfrm_state_delete),
	LSM_HOOK_INIT(xfrm_policy_lookup, selinux_xfrm_policy_lookup),
	LSM_HOOK_INIT(xfrm_state_pol_flow_match,
			selinux_xfrm_state_pol_flow_match),
	LSM_HOOK_INIT(xfrm_decode_session, selinux_xfrm_decode_session),
#endif

#ifdef CONFIG_KEYS
	LSM_HOOK_INIT(key_alloc, selinux_key_alloc),
	LSM_HOOK_INIT(key_free, selinux_key_free),
	LSM_HOOK_INIT(key_permission, selinux_key_permission),
	LSM_HOOK_INIT(key_getsecurity, selinux_key_getsecurity),
#endif

#ifdef CONFIG_AUDIT
	LSM_HOOK_INIT(audit_rule_init, selinux_audit_rule_init),
	LSM_HOOK_INIT(audit_rule_known, selinux_audit_rule_known),
	LSM_HOOK_INIT(audit_rule_match, selinux_audit_rule_match),
	LSM_HOOK_INIT(audit_rule_free, selinux_audit_rule_free),
#endif

#ifdef CONFIG_BPF_SYSCALL
	LSM_HOOK_INIT(bpf, selinux_bpf),
	LSM_HOOK_INIT(bpf_map, selinux_bpf_map),
	LSM_HOOK_INIT(bpf_prog, selinux_bpf_prog),
	LSM_HOOK_INIT(bpf_map_alloc_security, selinux_bpf_map_alloc),
	LSM_HOOK_INIT(bpf_prog_alloc_security, selinux_bpf_prog_alloc),
	LSM_HOOK_INIT(bpf_map_free_security, selinux_bpf_map_free),
	LSM_HOOK_INIT(bpf_prog_free_security, selinux_bpf_prog_free),
#endif
};

```

## 3. LSM模块生效（以SELinux和open为例）
```c
SYSCALL_DEFINE3(open, const char __user *, filename, int, flags, umode_t, mode)
{
	return ksys_open(filename, flags, mode);
}

static inline long ksys_open(const char __user *filename, int flags,
			     umode_t mode)
{
	if (force_o_largefile())
		flags |= O_LARGEFILE;
	return do_sys_open(AT_FDCWD, filename, flags, mode);
}

long do_sys_open(int dfd, const char __user *filename, int flags, umode_t mode)
{
	struct open_how how = build_open_how(flags, mode);
	return do_sys_openat2(dfd, filename, &how);
}

...

struct file *do_filp_open(int dfd, struct filename *pathname,
		const struct open_flags *op);

static struct file *path_openat(struct nameidata *nd,
			const struct open_flags *op, unsigned flags);
			
static int do_o_path(struct nameidata *nd, unsigned flags, struct file *file);

int vfs_open(const struct path *path, struct file *file);
...

int vfs_open(const struct path *path, struct file *file)
{
	file->f_path = *path;
	return do_dentry_open(file, d_backing_inode(path->dentry), NULL);
}
static int do_dentry_open(struct file *f,
			  struct inode *inode,
			  int (*open)(struct inode *, struct file *))
{
	...
	
	error = security_file_open(f);
	if (error)
		goto cleanup_all;

cleanup_all:
	if (WARN_ON_ONCE(error > 0))
		error = -EINVAL;
	fops_put(f->f_op);
	if (f->f_mode & FMODE_WRITER) {
		put_write_access(inode);
		__mnt_drop_write(f->f_path.mnt);
	}
cleanup_file:
	path_put(&f->f_path);
	f->f_path.mnt = NULL;
	f->f_path.dentry = NULL;
	f->f_inode = NULL;
	return error;
}
int security_file_open(struct file *file)
{
	int ret;

	ret = call_int_hook(file_open, 0, file);
	if (ret)
		return ret;

	return fsnotify_perm(file, MAY_OPEN);
}
#define call_int_hook(FUNC, IRC, ...) ({			\
	int RC = IRC;						\
	do {							\
		struct security_hook_list *P;			\
								\
		hlist_for_each_entry(P, &security_hook_heads.FUNC, list) { \
			RC = P->hook.FUNC(__VA_ARGS__);		\
			if (RC != 0)				\
				break;				\
		}						\
	} while (0);						\
	RC;							\
})
static int selinux_file_open(struct file *file)
{
	struct file_security_struct *fsec;
	struct inode_security_struct *isec;

	fsec = file->f_security;
	isec = inode_security(file_inode(file));
	/*
	 * Save inode label and policy sequence number
	 * at open-time so that selinux_file_permission
	 * can determine whether revalidation is necessary.
	 * Task label is already saved in the file security
	 * struct as its SID.
	 */
	fsec->isid = isec->sid;
	fsec->pseqno = avc_policy_seqno(&selinux_state);
	/*
	 * Since the inode label or policy seqno may have changed
	 * between the selinux_inode_permission check and the saving
	 * of state above, recheck that access is still permitted.
	 * Otherwise, access might never be revalidated against the
	 * new inode label or new policy.
	 * This check is not redundant - do not remove.
	 */
	return file_path_has_perm(file->f_cred, file, open_file_to_av(file));
}
```


## 4. LSM模块编程
实现一个获取当前执行进程的绝对路径的LSM模块，代码如下：
test\_lsm\_module.c
```c
#include <linux/security.h>
#include <linux/sysctl.h>
#include <linux/ptrace.h>
#include <linux/prctl.h>
#include <linux/ratelimit.h>
#include <linux/workqueue.h>
#include <linux/file.h>
#include <linux/fs.h>
#include <linux/dcache.h>
#include <linux/path.h>
#include <linux/kprobes.h>
#include <linux/module.h> 

static int (*register_security_p)(struct security_operations *ops);
static int (*unregister_security_p)(struct security_operations * ops);

// do nothing
int kprobe_pre(struct kprobe *p, struct pt_regs *regs)
{
        return 0;
}

static void* acquire_func_by_kprobe(char* func_name)
{
    void *symbol_addr=NULL;
    struct kprobe kp;

    do
    {
       memset(&kp, 0, sizeof(kp));
       kp.symbol_name = func_name;
       kp.pre_handler = kprobe_pre;
       if(register_kprobe(&kp) != 0)
       {
            symbol_addr=(void*)kp.addr;
            break;
       }
       //this is the address of  "symbol_name"
       symbol_addr = (void*)kp.addr;

       //now kprobe is not used any more,so unregister it
       unregister_kprobe(&kp);

    }while(false);

    return symbol_addr;
}

int execve_lsm_hook(struct linux_binprm *bprm)
{
    struct cred *currentCred;

    if (bprm->filename)
    {
        printk("file: %s\n", bprm->filename);
        //printk("file argument: %s\n",bprm->p);
    }
    else
    {
        printk("file exec\n");
    } 
    
    currentCred = current->cred;    
    printk(KERN_INFO "uid = %d\n", currentCred->uid);
    printk(KERN_INFO "gid = %d\n", currentCred->gid);
    printk(KERN_INFO "suid = %d\n", currentCred->suid);
    printk(KERN_INFO "sgid = %d\n", currentCred->sgid);
    printk(KERN_INFO "euid = %d\n", currentCred->euid);
    printk(KERN_INFO "egid = %d\n", currentCred->egid);  

    printk("comm: %s\n", current->comm);

    return 0;
} 

static struct security_operations test_security_ops = 
{
        .name = "test",
        .bprm_check_security = execve_lsm_hook,
};

static __init int test_init(void)
{
    int ret_val = -1;

    //获取register_security的导出地址
    register_security_p = acquire_func_by_kprobe("register_security");
    printk("register_security:%p\n", register_security_p);   
    if (!register_security_p)
    {
        printk("get register_security error\n");
    }  

    //获取unregister_security的导出地址
    unregister_security_p = acquire_func_by_kprobe("unregister_security");
    printk("unregister_security:%p\n", unregister_security_p);
    if (!unregister_security_p)
    {
        printk("get unregister_security error\n"); 
    }
     
    //注册LSMsbas
     //if (register_security_p && unregister_security_p)
     if (register_security_p)
    {
        ret_val = register_security_p(&test_security_ops); 
        printk("register_security:%d\n", ret_val);  
    }  

       return 0;
} 

static void test_cleanup(void)
{
    int ret_val=-1;

    //if (register_security_p && unregister_security_p)
    if (unregister_security_p)
    {
        ret_val = register_security_p(&test_security_ops); 
        printk("register_security:%d\n", ret_val);  
    }

    return;
} 

module_init(test_init);
module_exit(test_cleanup);

//一定要有这个声明，否则会有unknown module symbol error
MODULE_LICENSE("GPL");
```

Makefile
```mk
obj-m := execve_lsm_hook.o
PWD       := $(shell pwd)

all:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
    rm -rf *.o *~ core .*.cmd *.mod.c ./tmp_version *.ko modules.order  Module.symvers

clean_omit:
    rm -rf *.o *~ core .*.cmd *.mod.c ./tmp_version modules.order  Module.symvers
```


## References
1. 