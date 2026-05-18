/* Verify byte store synthesis (sb = lw + clear byte lane + insert + sw).
 * Writes a byte then reads the whole word back to verify neighbouring bytes unchanged. */

static volatile unsigned int buf[2];

int main(void)
{
    volatile unsigned char *p = (volatile unsigned char *)buf;

    /* store into each byte lane, verify only that lane changes */
    buf[0] = 0xAABBCCDD;
    *(volatile unsigned char *)(p + 0) = 0x11;
    if (buf[0] != 0xAABBCC11) return 1;

    buf[0] = 0xAABBCCDD;
    *(volatile unsigned char *)(p + 1) = 0x22;
    if (buf[0] != 0xAABB22DD) return 2;

    buf[0] = 0xAABBCCDD;
    *(volatile unsigned char *)(p + 2) = 0x33;
    if (buf[0] != 0xAA33CCDD) return 3;

    buf[0] = 0xAABBCCDD;
    *(volatile unsigned char *)(p + 3) = 0x44;
    if (buf[0] != 0x44BBCCDD) return 4;

    /* store zero — that byte must clear while others remain */
    buf[0] = 0xFFFFFFFF;
    *(volatile unsigned char *)(p + 0) = 0;
    if (buf[0] != 0xFFFFFF00) return 5;

    buf[0] = 0xFFFFFFFF;
    *(volatile unsigned char *)(p + 3) = 0;
    if (buf[0] != 0x00FFFFFF) return 6;

    /* store 0xFF into a zero word */
    buf[0] = 0;
    *(volatile unsigned char *)(p + 2) = 0xFF;
    if (buf[0] != 0x00FF0000) return 7;

    return 0;
}
