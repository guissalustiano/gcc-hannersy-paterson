#include <stdatomic.h>
atomic_int x;
void barrier(void) { atomic_thread_fence(memory_order_seq_cst); }
int load(void)     { return atomic_load(&x); }
void store(int v)  { atomic_store(&x, v); }
