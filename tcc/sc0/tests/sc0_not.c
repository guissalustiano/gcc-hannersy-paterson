/* ~x synthesized as: sub rd, x0, rs; addi rd, rd, -1 */
__attribute__((noreturn)) void test_not(int x) { volatile int r = ~x; __builtin_unreachable(); }
