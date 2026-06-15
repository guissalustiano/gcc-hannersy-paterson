/* lb/lbu synthesized: addr&-4 → lw → shift extract → sign/zero extend */
__attribute__((noreturn)) void test_lb (char          *p) { volatile int r = *p; __builtin_unreachable(); }
__attribute__((noreturn)) void test_lbu(unsigned char *p) { volatile int r = *p; __builtin_unreachable(); }
