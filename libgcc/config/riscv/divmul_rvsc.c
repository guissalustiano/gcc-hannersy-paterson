/* SImode multiply, divide and modulo for the rvsc targets.

   Upstream supplies these from config/riscv/div.S and config/riscv/muldi3.S,
   hand-written assembly.  Assembly bypasses the machine description entirely,
   so -mno-shift has no effect on it and those files assemble native slli/srli
   -- instructions the rvsc0 and rvsc1 targets do not implement.  A program
   that divides or multiplies would then execute them despite every object the
   compiler produced being clean.

   These C versions go through the ordinary synthesis path instead.  They are
   written to keep that synthesis cheap rather than to be idiomatic:

     - No right shifts.  On these targets a constant `>> 1' expands to a
       bit-extraction loop of about 159 instructions, while `<< 1' is a single
       add.  Both routines are therefore restructured to walk bits upward,
       shifting the operand or the mask left, never right.
     - Comparisons are kept to one per iteration, since an unsigned compare is
       itself synthesized from sub/xor/and.

   Semantics follow the RISC-V specification, matching the div.S they replace:
   division by zero yields all ones, and the remainder of a division by zero is
   the dividend.  INT_MIN / -1 wraps to INT_MIN, which falls out of doing the
   sign handling in the unsigned domain.  */

typedef int SItype __attribute__ ((mode (SI)));
typedef unsigned int USItype __attribute__ ((mode (SI)));

/* Restoring division, most significant bit first.  NUM is shifted left into
   REM one bit at a time, so the only shifts are left shifts.  Returns the
   quotient, or the remainder when MODWANTED.  */

static USItype
udivmodsi4 (USItype num, USItype den, int modwanted)
{
  USItype rem = 0;
  USItype quot = 0;
  int i;

  for (i = 0; i < 32; i++)
    {
      /* Doubling REM produces a 33-bit value whose top bit is the bit about to
	 be shifted out.  Capture it before the addition truncates it: if it is
	 set the true remainder already exceeds any 32-bit DEN, so the subtract
	 must happen even though the truncated REM may compare as smaller.
	 Without this the routine is wrong for every DEN >= 2^31.  Testing the
	 bit with an AND rather than a shift keeps the loop free of right
	 shifts, which is the whole point of this formulation.  */
      int carry = (rem & 0x80000000u) != 0;

      rem += rem;
      if (num & 0x80000000u)
	rem |= 1;
      num += num;
      quot += quot;
      if (carry || rem >= den)
	{
	  rem -= den;
	  quot |= 1;
	}
    }

  return modwanted ? rem : quot;
}

USItype
__udivsi3 (USItype a, USItype b)
{
  if (b == 0)
    return (USItype) -1;
  return udivmodsi4 (a, b, 0);
}

USItype
__umodsi3 (USItype a, USItype b)
{
  if (b == 0)
    return a;
  return udivmodsi4 (a, b, 1);
}

SItype
__divsi3 (SItype a, SItype b)
{
  USItype ua = (USItype) a;
  USItype ub = (USItype) b;
  USItype quot;
  int neg = 0;

  if (b == 0)
    return (SItype) -1;

  if (a < 0)
    {
      ua = -ua;
      neg = !neg;
    }
  if (b < 0)
    {
      ub = -ub;
      neg = !neg;
    }

  quot = udivmodsi4 (ua, ub, 0);
  return (SItype) (neg ? -quot : quot);
}

SItype
__modsi3 (SItype a, SItype b)
{
  USItype ua = (USItype) a;
  USItype ub = (USItype) b;
  USItype rem;
  int neg = 0;

  if (b == 0)
    return a;

  if (a < 0)
    {
      ua = -ua;
      neg = 1;
    }
  if (b < 0)
    ub = -ub;

  rem = udivmodsi4 (ua, ub, 1);
  return (SItype) (neg ? -rem : rem);
}

/* Shift-add multiply.  BIT walks upward and the consumed bit is cleared from
   B, so the loop still exits early on small multipliers without ever shifting
   right.  */

USItype
__mulsi3 (USItype a, USItype b)
{
  USItype res = 0;
  USItype bit = 1;

  while (b)
    {
      if (b & bit)
	{
	  res += a;
	  b -= bit;
	}
      a += a;
      bit += bit;
    }

  return res;
}
