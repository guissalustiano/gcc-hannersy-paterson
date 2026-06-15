# Test Infrastructure TODO

Items deferred from the thesis writing phase. Implement before collecting results data.

## 1. Add reference compiler to `default.nix`

Add `riscv32-none-elf-gcc` as the differential testing reference. Must NOT override `CC`/`CXX`
in the shell (which would break the custom GCC configure runs).

```nix
# In default.nix nativeBuildInputs, wrap it:
(pkgsCross.riscv32-embedded.buildPackages.gcc.override { ... })
# Or use a shellHook alias:
shellHook = ''
  alias riscv32-none-elf-ref-gcc="${pkgsCross.riscv32-embedded.buildPackages.gcc}/bin/riscv32-none-elf-gcc"
'';
```

Verify: `riscv32-none-elf-gcc --version` (or alias) available in shell without clobbering `$CC`.

---

## 2. Differential testing script — `scw/test/spike/run_diff_tests.py`

For each `behav_*.c`:
1. Compile with `rvsc1-unknown-elf-gcc -S -O1`
2. Compile with `riscv32-none-elf-gcc -march=rv32i -S -O1` (reference)
3. Assemble both with `riscv32-none-elf-as`
4. Link both with `startup32.S` + `link32.ld`
5. Run both on Spike `--isa=rv32i`
6. Compare exit codes — PASS if equal

Structure similar to `run_spike_tests.py`. Add to `sc1/justfile` as `just diff-test`.

---

## 3. rvsc0 startup — `scw/test/spike/startup0.S`

rvsc0 has no `jalr`, so the standard `call main` startup cannot be used.
rvsc0 test programs write their result to `tohost` directly and spin.

The startup for rvsc0 only needs to:
- Set up the stack pointer (if needed): `addi sp, x0, <stack_addr>` (addr < 2048)
- Provide the `tohost`/`fromhost` symbols in the `.htif` section (same as `startup32.S`)

The test `main()` must handle HTIF exit itself:
```c
// At end of rvsc0 test main():
volatile int *tohost = (volatile int *)TOHOST_ADDR;
*tohost = (result << 1) | 1;
while (1) {}  // beq x0, x0, .
```

---

## 4. Missing behavioral tests

### `scw/test/spike/behav_slt.c`
Cover SLT and SLTU synthesis:
- Signed comparisons: positive vs positive, negative vs positive, negative vs negative
- Unsigned comparisons: small vs large, wrapping values (0xFFFFFFFF)
- Edge cases: equal values, INT_MIN, INT_MAX

### `scw/test/spike/behav_sra.c`
Cover SRA synthesis:
- Positive number, shift 0, 1, 8, 31
- Negative number, shift 0, 1, 8, 31 (must sign-extend)
- -1 shifted right by any amount must give -1

---

## 5. rvsc0 differential test programs — `scw/test/spike/behav_sc0_*.c`

Adapt existing `behav_*.c` tests for rvsc0. Differences from rvsc1 tests:
- No function calls (all logic must be inlined into one function body)
- `main()` writes `(result << 1) | 1` to `tohost` via `sw` and loops
- Same differential testing approach: compare exit code vs `riscv32-none-elf-gcc`

Candidate operations to test in rvsc0: NOT, XOR, shifts, ANDI, ORI, LB/LBU, LH/LHU, SB, SH.

---

## 6. Data collection for Results chapter

After the above is implemented, collect:

### Program Size (Section 6.2)
```sh
riscv32-none-elf-objdump -d <elf> | grep -c '^\s\+[0-9a-f]\+:'
```
Programs: `behav_xor.c`, `behav_shift_var.c` (shift=8), `behav_sb.c`
Compilers: rvsc0, rvsc1, rvsc3

### Program Performance (Section 6.3)
```sh
spike --log-commits --isa=rv32i <elf> 2>&1 | grep -c '^[0-9]'
```
Same programs + SLL with shift amounts 0, 1, 8, 16, 31.
Expected SLL formula: 3 + 4b retired instructions.
