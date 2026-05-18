/* Verify halfword store synthesis (sh = lw + clear lane + insert + sw).
 * Only tests 2-byte aligned stores (the natural case for 'sh').
 * Reads back via volatile int * to confirm neighbouring bytes unchanged. */

static volatile unsigned int buf[2];

int main(void)
{
    volatile unsigned char *p = (volatile unsigned char *)buf;

    /* aligned store at offset 0 — halfword in bits 15:0 */
    buf[0] = 0xDEADBEEF;
    *(volatile unsigned short *)(p + 0) = 0x1234;
    if (buf[0] != 0xDEAD1234) return 1;

    /* aligned store at offset 2 — halfword in bits 31:16 */
    buf[0] = 0xDEADBEEF;
    *(volatile unsigned short *)(p + 2) = 0x5678;
    if (buf[0] != 0x5678BEEF) return 2;

    /* store zero at offset 0 — lower half clears, upper unchanged */
    buf[0] = 0xFFFFFFFF;
    *(volatile unsigned short *)(p + 0) = 0;
    if (buf[0] != 0xFFFF0000) return 3;

    /* store zero at offset 2 — upper half clears, lower unchanged */
    buf[0] = 0xFFFFFFFF;
    *(volatile unsigned short *)(p + 2) = 0;
    if (buf[0] != 0x0000FFFF) return 4;

    /* store 0xFFFF at offset 0 into zero word */
    buf[0] = 0;
    *(volatile unsigned short *)(p + 0) = 0xFFFF;
    if (buf[0] != 0x0000FFFF) return 5;

    /* store 0xFFFF at offset 2 into zero word */
    buf[0] = 0;
    *(volatile unsigned short *)(p + 2) = 0xFFFF;
    if (buf[0] != 0xFFFF0000) return 6;

    /* two consecutive stores, verify both words independent */
    buf[0] = 0; buf[1] = 0;
    *(volatile unsigned short *)(p + 0) = 0xAAAA;
    *(volatile unsigned short *)(p + 2) = 0xBBBB;
    if (buf[0] != 0xBBBBAAAA) return 7;

    return 0;
}
