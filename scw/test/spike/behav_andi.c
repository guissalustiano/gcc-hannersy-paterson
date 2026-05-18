/* Verify andi synthesis: !TARGET_ANDI emits li t, imm; and rd, rs, t.
 * Also exercises the zero_extendqi split which uses andi 0xff. */

__attribute__((noinline))
static int andi_fn(int a) { return a & 5; }

__attribute__((noinline))
static int and_reg(int a, int b) { return a & b; }

__attribute__((noinline))
static unsigned int zext_byte(unsigned int a) { return a & 0xFF; }

int main(void)
{
    if (andi_fn(0)          != 0)           return 1;
    if (andi_fn(5)          != 5)           return 2;
    if (andi_fn(-1)         != 5)           return 3;
    if (andi_fn(0xFA)       != (0xFA & 5))  return 4;
    if (andi_fn(0xFFFFFFFF) != 5)           return 5;

    if (and_reg(0, 0xFFFFFFFF) != 0)           return 10;
    if (and_reg((int)0xFFFFFFFF, (int)0xFFFFFFFF) != (int)0xFFFFFFFF) return 11;
    if (and_reg(0xAAAAAAAA, 0x55555555) != 0)  return 12;
    if (and_reg(0xFF00FF00, 0xFFFFFFFF) != (int)0xFF00FF00) return 13;

    /* zero-extend byte (andi 0xff) */
    if (zext_byte(0xABCDEF12) != 0x12)  return 20;
    if (zext_byte(0xFFFFFFFF) != 0xFF)  return 21;
    if (zext_byte(0x00000080) != 0x80)  return 22;
    if (zext_byte(0)          != 0)     return 23;

    return 0;
}
