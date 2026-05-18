/* Verify signed byte load synthesis (lb = lw + align + ashr for sign extension).
 * volatile prevents the compiler from folding memory accesses. */

static volatile unsigned int buf[2];

int main(void)
{
    volatile signed char *p = (volatile signed char *)buf;

    buf[0] = 0x01020304;   /* bytes: 04 03 02 01 */

    if (p[0] != 4) return 1;
    if (p[1] != 3) return 2;
    if (p[2] != 2) return 3;
    if (p[3] != 1) return 4;

    /* high bit set → must sign-extend to negative */
    buf[0] = 0x80818283;   /* bytes: 83 82 81 80 */
    if (p[0] != (signed char)0x83) return 5;
    if (p[1] != (signed char)0x82) return 6;
    if (p[2] != (signed char)0x81) return 7;
    if (p[3] != (signed char)0x80) return 8;

    /* -1 = 0xFF */
    buf[0] = 0xFFFFFFFF;
    if (p[0] != -1) return 9;

    return 0;
}
