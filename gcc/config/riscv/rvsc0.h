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
   -mno-lui routes large constants through a constant pool accessed via
   lw rd, %lo(pool)(x0); the rvsc0 linker script guarantees pool < 2048.
   -mno-auipc redirects PC-relative addressing to absolute lui+lo12, but
   since lui itself is disabled the effect is that symbol references also
   go through the pool.  */
#undef CC1_SPEC
#define CC1_SPEC \
  "%{!mfence:-mno-fence} %{!mauipc:-mno-auipc} %{!mshift:-mno-shift}" \
  " %{!mxor:-mno-xor} %{!mori:-mno-ori} %{!mandi:-mno-andi}" \
  " %{!mslt:-mno-slt} %{!mslti:-mno-slti}" \
  " %{!mbne:-mno-bne} %{!mblt:-mno-blt} %{!mbge:-mno-bge}" \
  " %{!mbltu:-mno-bltu} %{!mbgeu:-mno-bgeu}" \
  " %{!mbyte:-mno-byte} %{!mhalf:-mno-half}" \
  " %{!mlui:-mno-lui}"
