__attribute__((noreturn)) void test_add(int a, int b) { volatile int r = a + b; __builtin_unreachable(); }
__attribute__((noreturn)) void test_sub(int a, int b) { volatile int r = a - b; __builtin_unreachable(); }
