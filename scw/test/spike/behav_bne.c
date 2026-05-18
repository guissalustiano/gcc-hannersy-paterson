/* Verify bne synthesis: beq a,b,skip; jump L; skip: (when !TARGET_BNE). */

__attribute__((noinline))
static int neq(int a, int b) { return a != b; }

__attribute__((noinline))
static int count_ne(int *arr, int n, int val)
{
    int cnt = 0, i;
    for (i = 0; i < n; i++)
        if (arr[i] != val)
            cnt++;
    return cnt;
}

static int data[8];

int main(void)
{
    /* branch not taken (a == b) */
    if (neq(0, 0)   != 0) return 1;
    if (neq(-1, -1) != 0) return 2;

    /* branch taken (a != b) */
    if (neq(0, 1)   != 1) return 3;
    if (neq(1, 0)   != 1) return 4;
    if (neq(-1, 1)  != 1) return 5;

    /* loop exercising bne repeatedly */
    data[0] = 1; data[1] = 2; data[2] = 1; data[3] = 3;
    data[4] = 1; data[5] = 4; data[6] = 1; data[7] = 5;
    if (count_ne(data, 8, 1) != 4) return 10;
    if (count_ne(data, 8, 9) != 8) return 11;
    if (count_ne(data, 0, 1) != 0) return 12;

    return 0;
}
