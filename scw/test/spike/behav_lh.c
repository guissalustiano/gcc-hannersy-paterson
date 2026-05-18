/* Verify signed halfword load synthesis (lh = lw + align + ashr for sign extension).
 * Only tests 2-byte aligned accesses (the natural case for 'lh').
 * volatile prevents the compiler from folding memory accesses. */

static volatile unsigned int buf[2];

int main(void)
{
    volatile short *p = (volatile short *)buf;

    /* positive value: high bit 0, no sign extension */
    buf[0] = 0x7FFF0001;
    if (p[0] != 1)       return 1;   /* lower halfword */
    if (p[1] != 0x7FFF)  return 2;   /* upper halfword */

    /* negative: high bit 1, must sign-extend */
    buf[0] = 0x80008000;
    if (p[0] != (short)0x8000) return 3;   /* lower halfword */
    if (p[1] != (short)0x8000) return 4;   /* upper halfword */

    /* 0xFF80 → -128 */
    buf[0] = 0x00000080;
    if (p[0] != 0x0080) return 5;   /* positive 128 in lower */

    buf[0] = 0xFF800000;
    if (p[1] != (short)0xFF80) return 6;   /* negative in upper */

    /* -1 */
    buf[0] = 0xFFFFFFFF;
    if (p[0] != -1) return 7;
    if (p[1] != -1) return 8;

    /* zero */
    buf[0] = 0;
    if (p[0] != 0) return 9;

    return 0;
}
