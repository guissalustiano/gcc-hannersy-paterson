/* bne synthesized: sub t,a,b; beq t,x0,skip; beq x0,x0,target */
__attribute__((noreturn)) void test_neq(int a, int b) { volatile int r = (a != b); __builtin_unreachable(); }
