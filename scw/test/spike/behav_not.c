/* Verify not synthesis: ~x = -x - 1 (sub + addi when !TARGET_XOR). */

__attribute__((noinline))
static int lnot(int x) { return ~x; }

int main(void)
{
    if (lnot(0)          != -1)         return 1;
    if (lnot(-1)         != 0)          return 2;
    if (lnot(1)          != -2)         return 3;
    if (lnot(-2)         != 1)          return 4;
    if (lnot(0x7FFFFFFF) != (int)0x80000000) return 5;
    if (lnot((int)0x80000000) != 0x7FFFFFFF) return 6;
    if (lnot(0x55555555) != (int)0xAAAAAAAA) return 7;
    if (lnot((int)0xAAAAAAAA) != 0x55555555) return 8;

    /* double-not is identity */
    if (lnot(lnot(0xDEADBEEF)) != (int)0xDEADBEEF) return 9;

    return 0;
}
