/* Verify blt/bge/bltu/bgeu synthesis via slt/sltu+beq when !TARGET_BLT etc. */

__attribute__((noinline)) static int lt(int a, int b)   { return a < b; }
__attribute__((noinline)) static int ge(int a, int b)   { return a >= b; }
__attribute__((noinline)) static int ltu(unsigned a, unsigned b) { return a < b; }
__attribute__((noinline)) static int geu(unsigned a, unsigned b) { return a >= b; }

__attribute__((noinline))
static int clamp(int x, int lo, int hi)
{
    if (x < lo) return lo;
    if (x >= hi) return hi - 1;
    return x;
}

int main(void)
{
    /* signed lt */
    if (lt(0, 1)   != 1) return 1;
    if (lt(1, 0)   != 0) return 2;
    if (lt(0, 0)   != 0) return 3;
    if (lt(-1, 0)  != 1) return 4;
    if (lt(0, -1)  != 0) return 5;
    if (lt(-2, -1) != 1) return 6;

    /* signed ge */
    if (ge(0, 1)   != 0) return 10;
    if (ge(1, 0)   != 1) return 11;
    if (ge(0, 0)   != 1) return 12;
    if (ge(-1, 0)  != 0) return 13;
    if (ge(0, -1)  != 1) return 14;

    /* unsigned lt */
    if (ltu(0u, 1u)            != 1) return 20;
    if (ltu(1u, 0u)            != 0) return 21;
    if (ltu(0u, 0u)            != 0) return 22;
    if (ltu(0x7FFFFFFFu, 0x80000000u) != 1) return 23;
    if (ltu(0x80000000u, 0x7FFFFFFFu) != 0) return 24;
    if (ltu(0xFFFFFFFFu, 0u)   != 0) return 25;

    /* unsigned ge */
    if (geu(0u, 1u)            != 0) return 30;
    if (geu(1u, 0u)            != 1) return 31;
    if (geu(0u, 0u)            != 1) return 32;
    if (geu(0xFFFFFFFFu, 0u)   != 1) return 33;

    /* clamp exercises both lt and ge in one function */
    if (clamp(5,  0, 10) != 5)  return 40;
    if (clamp(-1, 0, 10) != 0)  return 41;
    if (clamp(10, 0, 10) != 9)  return 42;

    return 0;
}
