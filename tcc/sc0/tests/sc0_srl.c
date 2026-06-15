__attribute__((noreturn)) void test_srl3    (unsigned x)         { volatile unsigned r = x >> 3; __builtin_unreachable(); }
__attribute__((noreturn)) void test_srl_var (unsigned x, int n)  { volatile unsigned r = x >> n; __builtin_unreachable(); }
