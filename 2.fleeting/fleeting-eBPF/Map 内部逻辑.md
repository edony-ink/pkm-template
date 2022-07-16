---
title: Map 内部逻辑
date: 2021-12-01 16:43
modify: 2021-12-01 16:46:15
author: edony.zpc
tags: 001-computer-technology ebpf/Map/innternal
---


# Map 内部逻辑
Linux bpf maps are used to share data among bpf programs and user applications. A bpf map could be created by simply declaring a bpf_elf_map struct. Under the hood, lots of things work together to set up the maps.

Tracing of an example
The following is a simple bpf program using a map:
```c
__section("maps")
struct bpf_elf_map counter_array = {
        .type           = BPF_MAP_TYPE_ARRAY,
        .size_key       = sizeof(uint32_t),
        .size_value     = sizeof(uint32_t),
        .pinning        = PIN_GLOBAL_NS,
        .max_elem       = 1,
};

__section("ingress")
int handle_ingress(struct __sk_buff *skb)
{
        int key = 0, *val;

        val = map_lookup_elem(&counter_array, &key);
        if (val)
                lock_xadd(val, 1);

        return TC_ACT_OK;
}
```
llvm could compile the C code into an ELF object file. The map section of the object file contains the counter_array struct. The ingress section contains bpf instructions of the function handle_ingress(), in which all references to the variable counter_array are not resolved. The disassembler prints the following bpf instructions for the map_lookup_elem() function call:
```
        18 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00         r1 = 0 ll
        85 00 00 00 01 00 00 00                                 call 1
```
As shown by bpf spec, the first instruction is a 16 bytes instruction with the following fields:

opcode is 0x18, which is BPF_LD | BPF_IMM | BPF_DW. The opcode loads an 64 bits immediate value to a destination register.

dst is 1, which refers to register r1.

src is 0, because the immediate value is inside the instruction.

imm is 0, because the value of counter_array is not yet resolved.

When tc loads the object file, it reads the map attributes from counter_array and calls bpf() syscall to create the bpf map. The bpf() syscall returns a file descriptor of the map object. tc then "resolves" references to counter_array with the file descriptor as show in the following code snippet in lib/bpf.c: bpf_apply_relo_map():
```c
        prog->insns[insn_off].src_reg = BPF_PSEUDO_MAP_FD;
        prog->insns[insn_off].imm = ctx->map_fds[map_idx];
```
BPF_PSEUDO_MAP_FD is 1, and here the map file descriptor is 6. The bpf instructions now becomes:
```
        18 11 00 00 06 00 00 00 00 00 00 00 00 00 00 00
        85 00 00 00 01 00 00 00   
```
When the kernel loads the above bpf instructions, it converts the file descriptor to the address of the map object. The call stack goes as follows:
```c
    sys_bpf()
    --> bpf_prog_load()
        --> bpf_check()
            --> replace_map_fd_with_map_ptr()
	    --> do_check()
                --> check_ld_imm()
                ==> check_func_arg()
            --> convert_pseudo_ld_imm64()
```
Function replace_map_fd_with_map_ptr() rewrites the instruction by the following code:
```c
        f = fdget(insn[0].imm);
        map = __bpf_map_get(f);
        addr = (unsigned long)map;
        insn[0].imm = (u32)addr;
        insn[1].imm = addr >> 32;
```
Function convert_pseudo_ld_imm64() resets the src field of the instruction:
```c
        if (insn->code == (BPF_LD | BPF_IMM | BPF_DW))
                insn->src_reg = 0;
```
Here the map address is 0xffff8881384aa200. The final bpf code is:
```
        18 01 00 00 00 a2 4a 38 00 00 00 00 81 88 ff ff
        85 00 00 00 30 86 01 00
```
So when calling map_lookup_elem() in the bpf code, the first argument counter_array is 0xffff8881384aa200.

Using map address directly?
In the original C code, can we use the map address directly when calling map_lookup_elem() as the following?
```c
        val = map_lookup_elem((void*)0xffff8881384aa200, &key);
```
The answer is no. Although the code compiles fine and could generate the final bpf instructions, the kernel bpf verifier rejects the instructions due to the do_check() function as shown in the previous call stack.

Function check_ld_imm() sets the type of the destination register(r1):
```c
        if (insn->src_reg == BPF_PSEUDO_MAP_FD)
                regs[insn->dst_reg].type = CONST_PTR_TO_MAP;
```
Function check_func_arg() is called for the next bpf instruction 0x85(call imm) . It checks if arguments of map_lookup_elem() have the expected types. Here the first argument r1 must have type ARG_CONST_MAP_PTR:
```c
	if (arg_type == ARG_CONST_MAP_PTR) {
		expected_type = CONST_PTR_TO_MAP;
		if (reg->type != expected_type)
			goto err_type;
	}
```
If we use the real map address in the original C code, this type check will fail because the src field of the 0x18 instruction is 0 and thus the type of register r1 is not set to CONST_PTR_TO_MAP.

Final thoughts
The bpf map in the above example must be created before loading the bpf program. There are cases that maps can only be created after the bpf program is loaded. For such cases, we could use maps of type BPF_MAP_TYPE_ARRAY_OF_MAPS or BPF_MAP_TYPE_HASH_OF_MAPS. I'll have a follow-up post for this.

## References
1. [Linux bpf map internals – Mechpen](https://mechpen.github.io/posts/2019-08-03-bpf-map/index.html)