__attribute__((noreturn)) void test_sra3    (int x)       { volatile int r = x >> 3; __builtin_unreachable(); }
__attribute__((noreturn)) void test_sra_var (int x, int n) { volatile int r = x >> n; __builtin_unreachable(); }
