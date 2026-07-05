/* Restructured __muldi3 / __multi3 for rvsc targets.

   The upstream multi3.c computes carry = (new_w_low < w_low) via cstore4
   AFTER the last outer-loop read of v_low.  On sc1, the SLTU synthesis for
   cstore4 produces several temporaries; the IRA sees a "hole" in v_low's
   outer-loop live range at that point and assigns those temporaries to
   v_low's hard register.  The inner-loop allocno for v_low (inside the SRL
   synthesis of v_low >>= 1) also lives in that register, but no reload is
   generated, so the SRL loop reads the corrupted SLTU value instead of
   v_low and the multiply returns a wrong result.

   Fix: shift v_low at the TOP of the loop body (before any SLTU code).
   After the shift, v_low is still needed for the while(v_low) condition, so
   it remains live throughout the SLTU sequence.  The SLTU temporaries then
   conflict with v_low and cannot be assigned to its register.

   Copyright (C) 2016-2026 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

GCC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

Under Section 7 of GPL version 3, you are granted additional
permissions described in the GCC Runtime Library Exception, version
3.1, as published by the Free Software Foundation.

You should have received a copy of the GNU General Public License and
a copy of the GCC Runtime Library Exception along with this program;
see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
<http://www.gnu.org/licenses/>.  */

#include "tconfig.h"
#include "tsystem.h"
#include "coretypes.h"
#include "tm.h"
#include "libgcc_tm.h"
#define LIBGCC2_UNITS_PER_WORD (__riscv_xlen / 8)

#include "libgcc2.h"

#if __riscv_xlen == 32
/* Our RV64 64-bit routines are equivalent to our RV32 32-bit routines.  */
# define __multi3 __muldi3
#endif

/* Compile at -O0 to prevent IRA from sharing registers between
   outer-loop variables and SLTU/SRL synthesis temporaries.  */
__attribute__ ((optimize ("O0")))
DWtype
__multi3 (DWtype u, DWtype v)
{
  const DWunion uu = {.ll = u};
  const DWunion vv = {.ll = v};
  DWunion w;
  UWtype u_low = uu.s.low;
  UWtype v_low = vv.s.low;
  UWtype u_low_msb;
  UWtype w_low = 0;
  UWtype new_w_low;
  UWtype w_high = 0;
  UWtype w_high_tmp = 0;
  UWtype w_high_tmp2x;
  UWtype v_low_lsb;

  /* Calculate low half part of u and v, and get a UDWtype result just like
     what __umulsidi3 do.  */
  do
    {
      /* Capture the LSB and shift v_low first so that v_low remains live
	 across the carry-detection code below (it is still needed for the
	 while condition).  This prevents the IRA from assigning SLTU
	 temporaries to v_low's hard register.  */
      v_low_lsb = v_low & 1;
      v_low >>= 1;

      new_w_low = w_low + u_low;
      w_high_tmp2x = w_high_tmp << 1;
      w_high_tmp += w_high;
      if (v_low_lsb)
	{
	  /* Use if/else (cbranch4) rather than an integer carry variable
	     (cstore4) so the SLTU result dies at the branch and does not
	     extend into the region where v_low's register is needed.  */
	  if (new_w_low < w_low)
	    {
	      w_low = new_w_low;
	      w_high = w_high_tmp + 1;
	    }
	  else
	    {
	      w_low = new_w_low;
	      w_high = w_high_tmp;
	    }
	}
      u_low_msb = (u_low >> ((sizeof (UWtype) * 8) - 1));
      u_low <<= 1;
      w_high_tmp = u_low_msb | w_high_tmp2x;
    }
  while (v_low);

  w.s.low = w_low;
  w.s.high = w_high;

  if (uu.s.high)
    w.s.high = w.s.high + __muluw3(vv.s.low, uu.s.high);

  if (vv.s.high)
    w.s.high += __muluw3(uu.s.low, vv.s.high);

  return w.ll;
}
