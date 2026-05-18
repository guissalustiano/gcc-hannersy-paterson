OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS
{
    . = 0x80000000;

    .text.entry : { *(.text.entry) }
    .text       : { *(.text .text.*) }
    .rodata     : { *(.rodata .rodata.*) }
    .data       : { *(.data .data.*) }
    .sdata      : { *(.sdata .sdata.*) }

    .bss        : {
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        *(COMMON)
    }

    . = ALIGN(16);
    _stack_bottom = .;
    . = . + 0x10000;    /* 64 KiB stack */
    _stack_top = .;

    .htif       : { *(.htif) }
}
