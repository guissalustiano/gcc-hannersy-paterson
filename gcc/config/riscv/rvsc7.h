/* Target macros for rvsc7-unknown-elf targets.
   Educational RISC-V processor: rv64imafd_zicsr — integer, multiply/divide,
   atomics, and single/double-precision floating point (fence enabled).
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

/* sc7 adds the A extension (atomic memory operations) to sc6 (rv64imfd_zicsr).
   The default arch rv64imafd_zicsr and lp64d ABI are set in config.gcc.  */
