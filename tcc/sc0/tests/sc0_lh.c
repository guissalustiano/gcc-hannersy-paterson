/* lh/lhu synthesized: addr&-4 → lw → shift extract → sign/zero extend */
__attribute__((noreturn)) void test_lh (short          *p) { volatile int r = *p; __builtin_unreachable(); }
__attribute__((noreturn)) void test_lhu(unsigned short *p) { volatile int r = *p; __builtin_unreachable(); }
