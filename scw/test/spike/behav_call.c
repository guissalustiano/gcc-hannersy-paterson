/* Verify function call synthesis (jalr via lui+jalr when !TARGET_AUIPC).
 * Uses function pointers to force indirect calls, and deep call chains
 * to stress the return address mechanism. */

__attribute__((noinline)) static int add1(int x) { return x + 1; }
__attribute__((noinline)) static int mul2(int x) { return x + x; }
__attribute__((noinline)) static int sub1(int x) { return x - 1; }

typedef int (*fn_t)(int);

__attribute__((noinline))
static int apply(fn_t f, int x) { return f(x); }

__attribute__((noinline))
static int chain(int x)
{
    x = add1(x);
    x = mul2(x);
    x = sub1(x);
    return x;
}

/* recursive fibonacci to stress call/return */
__attribute__((noinline))
static int fib(int n)
{
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}

int main(void)
{
    /* direct calls */
    if (add1(0)  != 1)   return 1;
    if (add1(41) != 42)  return 2;
    if (mul2(21) != 42)  return 3;
    if (sub1(43) != 42)  return 4;

    /* indirect calls via function pointer */
    if (apply(add1, 5) != 6)  return 10;
    if (apply(mul2, 5) != 10) return 11;
    if (apply(sub1, 5) != 4)  return 12;

    /* chained calls — tests that ra is saved/restored correctly */
    if (chain(0) != 1)   return 20;  /* (0+1)*2-1 = 1 */
    if (chain(5) != 11)  return 21;  /* (5+1)*2-1 = 11 */

    /* recursion */
    if (fib(0)  != 0)  return 30;
    if (fib(1)  != 1)  return 31;
    if (fib(10) != 55) return 32;

    return 0;
}
