---
title: ALU Sanitation
date: 2021-12-17 15:14:13
modify: 2021-12-17 15:14:13
author: edony.zpc
tags: 001-computer-technology ebpf/verifier/ALU
---

# ALU Sanitation

In response to a large number of security vulnerabilities that were due to bugs in the verifier, a feature called “ALU sanitation” was introduced. The idea is to supplement the verifier’s static range checks with runtime checks on the actual values being processed by the program. Recall that the only permitted calculations with pointers are to add or subtract a scalar. For every arithmetic operation that involves a pointer and a scalar register (as opposed to an immediate), an alu_limit is determined as the maximal absolute value that can safely be added to or subtracted from to the pointer without exceeding the allowable range.

Pointer arithmetic where the sign of the scalar operand is unknown is disallowed. For the rest of this subsection, assume that each scalar is treated as positive; the negative case is analogous.

Before each arithmetic instruction that has an alu_limit, the following sequence of instructions is added. Note that off_reg is the register containing the scalar value, and BPF_REG_AX is an auxiliary register.

BPF_MOV32_IMM(BPF_REG_AX, aux->alu_limit - 1) BPF_ALU64_REG(BPF_SUB, BPF_REG_AX, off_reg) BPF_ALU64_REG(BPF_OR, BPF_REG_AX, off_reg) BPF_ALU64_IMM(BPF_NEG, BPF_REG_AX, 0) BPF_ALU64_IMM(BPF_ARSH, BPF_REG_AX, 63) BPF_ALU64_REG(BPF_AND, off_reg, BPF_REG_AX)

If the scalar exceeds alu_limit, then the first subtraction will be negative, so that the leftmost bit of BPF_REG_AX will be set. Similarly, if the scalar that is supposed to be positive is in fact negative, the BPF_OR instruction will set the leftmost bit of BPF_REG_AX. The negation followed by the arithmetic shift will then fill BPF_REG_AX with all 0s, so that the BPF_AND will force off_reg to zero, replacing the offending scalar. On the other hand, if the scalar falls within the appropriate range 0 <= off_reg <= alu_limit, the arithmetic shift will fill BPF_REG_AX with all 1s, so that the BPF_AND will leave the scalar register unchanged.

To make sure that setting the register to 0 does not itself introduce a new out-of-bounds condition, the verifier will track an additional “speculative” branch where the operand is treated as 0.



## References
1. [Zero Day Initiative — CVE-2020-8835: Linux Kernel Privilege Escalation via Improper eBPF Program Verification](https://www.zerodayinitiative.com/blog/2020/4/8/cve-2020-8835-linux-kernel-privilege-escalation-via-improper-ebpf-program-verification)