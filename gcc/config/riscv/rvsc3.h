/* Target macros for rvsc3-unknown-elf targets.
   Educational RISC-V processor: full rv32i base ISA (fence enabled).
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

/* sc3 supports the full rv32i base ISA including fence instructions.
   TARGET_FENCE has Init(1) in riscv.opt, so fence is enabled by default
   without any CC1_SPEC override.  */
