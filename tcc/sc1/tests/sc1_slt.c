int slt(int a, int b) { return a < b; }
int sltu(unsigned a, unsigned b) { return a < b; }
int sge(int a, int b) { return a >= b; }
int sgeu(unsigned a, unsigned b) { return a >= b; }
int branch_lt(int a, int b, int x, int y) { return a < b ? x : y; }
int branch_ltu(unsigned a, unsigned b, int x, int y) { return a < b ? x : y; }
int slt_imm(int a) { return a < 5; }
int sltu_imm(unsigned a) { return a < 5u; }
int sge_imm(int a) { return a >= 5; }
