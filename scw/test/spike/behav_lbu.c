/* Verify unsigned byte load synthesis (lbu = lw + align + extract).
 * Tests all four byte offsets within a word.
 * volatile prevents the compiler from folding memory accesses. */

static volatile unsigned int buf[2];

int main(void)
{
    volatile unsigned char *p = (volatile unsigned char *)buf;

    buf[0] = 0x11223344;   /* bytes: 44 33 22 11 */

    if (p[0] != 0x44) return 1;
    if (p[1] != 0x33) return 2;
    if (p[2] != 0x22) return 3;
    if (p[3] != 0x11) return 4;

    /* high bit set — must not sign-extend */
    buf[0] = 0xAABBCCDD;
    if (p[0] != 0xDD) return 5;
    if (p[1] != 0xCC) return 6;
    if (p[2] != 0xBB) return 7;
    if (p[3] != 0xAA) return 8;

    /* zero */
    buf[0] = 0;
    if (p[0] != 0) return 9;

    return 0;
}
