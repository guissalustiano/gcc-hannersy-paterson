/* Verify xor synthesis: De Morgan identity ~(a&b) & (a|b) for register form,
 * and li+or for immediate form. */

__attribute__((noinline))
static int xor_reg(int a, int b) { return a ^ b; }

__attribute__((noinline))
static int xor_imm(int a) { return a ^ 5; }

int main(void)
{
    /* basic identity */
    if (xor_reg(0, 0)         != 0)          return 1;
    if (xor_reg(0xFFFFFFFF, 0xFFFFFFFF) != 0) return 2;
    if (xor_reg(0xAAAAAAAA, 0x55555555) != (int)0xFFFFFFFF) return 3;
    if (xor_reg(0xF0F0F0F0, 0x0F0F0F0F) != (int)0xFFFFFFFF) return 4;
    if (xor_reg(0x12345678, 0x12345678) != 0) return 5;

    /* xor is its own inverse */
    if (xor_reg(xor_reg(0xDEADBEEF, 0x12345678), 0x12345678) != (int)0xDEADBEEF) return 6;

    /* immediate form */
    if (xor_imm(0)  != 5)  return 10;
    if (xor_imm(5)  != 0)  return 11;
    if (xor_imm(-1) != -6) return 12;   /* ~5 in two's complement */
    if (xor_imm(0xAA) != (0xAA ^ 5)) return 13;

    return 0;
}
