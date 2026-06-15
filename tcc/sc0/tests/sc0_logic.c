/* xor synthesized via De Morgan: ~(a&b) & (a|b) */
__attribute__((noreturn)) void test_and(int a, int b) { volatile int r = a & b; __builtin_unreachable(); }
__attribute__((noreturn)) void test_or (int a, int b) { volatile int r = a | b; __builtin_unreachable(); }
__attribute__((noreturn)) void test_xor(int a, int b) { volatile int r = a ^ b; __builtin_unreachable(); }
