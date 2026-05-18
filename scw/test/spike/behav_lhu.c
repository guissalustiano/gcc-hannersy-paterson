/* Verify unsigned halfword load synthesis (lhu = lw + align + extract).
 * buf is volatile so the compiler cannot fold memory accesses away. */

static volatile unsigned int buf[4];

int main(void)
{
    volatile unsigned char *p = (volatile unsigned char *)buf;

    buf[0] = 0xDDCCBBAA;   /* bytes at 0..3: AA BB CC DD */
    buf[1] = 0x11EEE4E3;   /* bytes at 4..7: E3 E4 EE 11 */

    /* aligned: offset 0 → bytes AA BB → 0xBBAA */
    if (*(volatile unsigned short *)(p + 0) != 0xBBAA) return 1;
    /* offset 2 → bytes CC DD → 0xDDCC */
    if (*(volatile unsigned short *)(p + 2) != 0xDDCC) return 2;
    /* unaligned: offset 1 → bytes BB CC → 0xCCBB */
    if (*(volatile unsigned short *)(p + 1) != 0xCCBB) return 3;
    /* offset 3 → bytes DD E3 → 0xE3DD */
    if (*(volatile unsigned short *)(p + 3) != 0xE3DD) return 4;
    /* offset 4 → bytes E3 E4 → 0xE4E3 */
    if (*(volatile unsigned short *)(p + 4) != 0xE4E3) return 5;
    /* offset 5 → bytes E4 EE → 0xEEE4 */
    if (*(volatile unsigned short *)(p + 5) != 0xEEE4) return 6;
    /* zero value */
    buf[0] = 0;
    if (*(volatile unsigned short *)(p + 0) != 0) return 7;

    return 0;
}
