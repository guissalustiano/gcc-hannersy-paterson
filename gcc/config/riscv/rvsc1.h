/* Target macros for rvsc1-unknown-elf targets.
   Educational RISC-V processor: rv32i subset — lw, sw, beq, add, addi, sub,
   and, or (sc0) plus jalr and lui.  No auipc; no fence.
   Copyright (C) 2024-2026 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3, or (at your option)
any later version.

GCC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GCC; see the file COPYING3.  If not see
<http://www.gnu.org/licenses/>.  */

#include "elf.h"

/* sc1 adds jalr and lui to sc0 (rv32i base subset) but does not implement
   auipc, fence, shift, or xor/xori instructions.  Suppress all by default.
   -mno-auipc redirects PC-relative addressing to absolute lui+lo12 and forces
   function calls through a register (lui+jalr).
   -mno-shift synthesizes sll/srl/sra via loops using add/and/or/beq.
   -mno-xor synthesizes not (~x) via sub+addi; plain xor synthesis is future work.  */
#undef CC1_SPEC
#define CC1_SPEC \
  "%{!mfence:-mno-fence} %{!mauipc:-mno-auipc} %{!mshift:-mno-shift} %{!mxor:-mno-xor} %{!mori:-mno-ori} %{!mandi:-mno-andi}"
