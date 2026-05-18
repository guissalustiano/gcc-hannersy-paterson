/* Bare-metal HTIF startup for rv64 Spike targets.
 * Assembled by riscv64-none-elf-as (full rv64i), not the restricted custom compiler.
 * HTIF protocol: write (exitcode << 1) | 1 to tohost; spike exits with exitcode. */

        .section .text.entry
        .globl  _start
_start:
        la      sp, _stack_top
        call    main
        /* a0 = main() return value; convert to HTIF word */
        slli    a0, a0, 1
        ori     a0, a0, 1
        la      t0, tohost
        sd      a0, 0(t0)
1:      j       1b

        .section .htif, "aw", @progbits
        .align  6
        .globl  tohost
tohost:   .dword 0
        .globl  fromhost
fromhost: .dword 0
