/* Verify variable-shift synthesis: sll/srl/sra by runtime count.
 * sc1 synthesizes these as count-down loops. */

__attribute__((noinline))
static int vsll(int x, int n) { return x << n; }

__attribute__((noinline))
static unsigned int vsrl(unsigned int x, int n) { return x >> n; }

__attribute__((noinline))
static int vsra(int x, int n) { return x >> n; }

int main(void)
{
    int i;

    /* sll by 0..31 for value 1 */
    for (i = 0; i < 32; i++) {
        if (vsll(1, i) != (1 << i)) return i + 1;
    }

    /* srl: 0x80000000 >> n should equal 0x80000000 / 2^n */
    if (vsrl(0x80000000u, 0)  != 0x80000000u) return 40;
    if (vsrl(0x80000000u, 1)  != 0x40000000u) return 41;
    if (vsrl(0x80000000u, 31) != 1u)          return 42;
    if (vsrl(0xFFFFFFFFu, 4)  != 0x0FFFFFFFu) return 43;
    if (vsrl(0u,          8)  != 0u)           return 44;

    /* sra: negative stays negative */
    if (vsra(-1, 0)  != -1)  return 50;
    if (vsra(-1, 31) != -1)  return 51;
    if (vsra(-256, 4) != -16) return 52;
    if (vsra(256,  4) != 16)  return 53;

    /* shift by 0 is identity */
    if (vsll(0xABCD1234, 0) != (int)0xABCD1234) return 60;
    if (vsrl(0xABCD1234u, 0) != 0xABCD1234u)    return 61;
    if (vsra((int)0xABCD1234, 0) != (int)0xABCD1234) return 62;

    return 0;
}
