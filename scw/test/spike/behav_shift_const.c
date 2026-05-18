/* Verify constant-shift synthesis: sll, srl, sra.
 * sc1 synthesizes all three as loops/repeated adds; verify results match. */

__attribute__((noinline))
static int sll(int x, int n) { (void)n; return x << 3; }

__attribute__((noinline))
static unsigned int srl(unsigned int x, int n) { (void)n; return x >> 3; }

__attribute__((noinline))
static int sra(int x, int n) { (void)n; return x >> 3; }

int main(void)
{
    /* sll (logical left shift) */
    if (sll(1,  0) != 8)          return 1;
    if (sll(3,  0) != 24)         return 2;
    if (sll(-1, 0) != -8)         return 3;  /* 0xFFFFFFF8 */
    if (sll(0,  0) != 0)          return 4;

    /* srl (logical right shift — zeros fill from left) */
    if (srl(0x80000000u, 0) != 0x10000000u) return 5;
    if (srl(0xFFFFFFFFu, 0) != 0x1FFFFFFFu) return 6;
    if (srl(0u,          0) != 0u)           return 7;
    if (srl(8u,          0) != 1u)           return 8;

    /* sra (arithmetic right shift — sign bit propagates) */
    if (sra(8,          0) != 1)    return 9;
    if (sra(-8,         0) != -1)   return 10;
    if (sra(-1,         0) != -1)   return 11;
    if (sra(0x7FFFFFFF, 0) != 0x0FFFFFFF) return 12;

    return 0;
}
