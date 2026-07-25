/* Target macros for rvsc0-unknown-elf targets.
   Educational RISC-V processor: rv32i subset — lw, sw, beq, add, addi, sub,
   and, or.  No lui, jalr, auipc, fence, shift, xor/xori, or ordered branches.
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

/* sc0 is the 8-instruction single-cycle processor from Chapter 4.4 of
   Hennessy & Patterson.  It lacks lui and jalr (added by sc1), so function
   calls are impossible; only single-function programs compile correctly.
   -mno-lui synthesizes large integer constants with addi/add only (split
   the 20-bit lui immediate into two 10-bit halves, build with shifts) --
   no memory access, so correctness does not depend on where the program
   is loaded.  An earlier version of this target routed such constants
   through a linker-placed constant pool addressed as lw rd,%lo(pool)(x0),
   which is only correct if the pool links below address 2048; that does
   not hold in general (nor for this project's own Spike behavioral tests,
   which load at 0x80000000), so it was replaced by the addi/add synthesis.
   Symbol references (e.g. addresses of global variables) still require
   lui and remain unsupported: their addresses are link-time-unknown and
   RISC-V relocations only support the standard 20-bit/12-bit lui/addi
   split, not this target's custom 10/10-bit split.  */
#undef CC1_SPEC
#define CC1_SPEC \
  "%{!mfence:-mno-fence} %{!mauipc:-mno-auipc} %{!mshift:-mno-shift}" \
  " %{!mxor:-mno-xor} %{!mori:-mno-ori} %{!mandi:-mno-andi}" \
  " %{!mslt:-mno-slt} %{!mslti:-mno-slti}" \
  " %{!mbne:-mno-bne} %{!mblt:-mno-blt} %{!mbge:-mno-bge}" \
  " %{!mbltu:-mno-bltu} %{!mbgeu:-mno-bgeu}" \
  " %{!mbyte:-mno-byte} %{!mhalf:-mno-half}" \
  " %{!mlui:-mno-lui}"
