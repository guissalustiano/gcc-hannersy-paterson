/* constant sll unrolled to N × (add rd, rd, rd); variable sll uses beq countdown loop */
__attribute__((noreturn)) void test_sll3    (int x)       { volatile int r = x << 3; __builtin_unreachable(); }
__attribute__((noreturn)) void test_sll_var (int x, int n) { volatile int r = x << n; __builtin_unreachable(); }
