/* Verify ori synthesis: !TARGET_ORI emits li t, imm; or rd, rs, t. */

__attribute__((noinline))
static int ori_fn(int a) { return a | 5; }

__attribute__((noinline))
static int or_reg(int a, int b) { return a | b; }

int main(void)
{
    if (ori_fn(0)          != 5)           return 1;
    if (ori_fn(5)          != 5)           return 2;
    if (ori_fn(-1)         != -1)          return 3;
    if (ori_fn(0xA0)       != (0xA0 | 5)) return 4;
    if (ori_fn(0xFFFFFFFA) != (int)0xFFFFFFFF) return 5;

    if (or_reg(0, 0)             != 0)          return 10;
    if (or_reg(0xAAAAAAAA, 0x55555555) != (int)0xFFFFFFFF) return 11;
    if (or_reg(0xFF00FF00, 0x00FF00FF) != (int)0xFFFFFFFF) return 12;
    if (or_reg(0, (int)0xDEADBEEF)  != (int)0xDEADBEEF)  return 13;

    return 0;
}
